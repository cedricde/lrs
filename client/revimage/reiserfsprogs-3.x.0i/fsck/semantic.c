/*
 * Copyright 1996-1999 Hans Reiser
 */
#include "fsck.h"


struct key root_dir_key = {REISERFS_ROOT_PARENT_OBJECTID,
			   REISERFS_ROOT_OBJECTID, {{0, 0},}};
struct key parent_root_dir_key = {0, REISERFS_ROOT_PARENT_OBJECTID, {{0, 0},}};
struct key lost_found_dir_key = {REISERFS_ROOT_OBJECTID, 0, {{0, 0}, }};


struct path_key
{
    struct short_key
    {
        __u32 k_dir_id;
        __u32 k_objectid;
    } key;
    struct path_key * next, * prev;
};

struct path_key * head_key = NULL;
struct path_key * tail_key = NULL;

void check_path_key(struct key * key)
{
    struct path_key * cur = head_key;

    while(cur != NULL)
    {
        if (!comp_short_keys(&cur->key, key))
            die("\nsemantic check: loop found %k", key);
        cur = cur->next;
    }
}

void add_path_key(struct key * key)
{
    check_path_key(key);

    if (tail_key == NULL)
    {
        tail_key = getmem(sizeof(struct path_key));
        head_key = tail_key;
        tail_key->prev = NULL;
    }else{
        tail_key->next = getmem(sizeof(struct path_key));
        tail_key->next->prev = tail_key;
        tail_key = tail_key->next;
    }
    copy_short_key (&tail_key->key, key);
    tail_key->next = NULL;
}

void del_path_key()
{
    if (tail_key == NULL)
        die("wrong path_key structure");

    if (tail_key->prev == NULL)
    {
        freemem(tail_key);
        tail_key = head_key = NULL;
    }else{
        tail_key = tail_key->prev;
        freemem(tail_key->next);
        tail_key->next = NULL;
    }
}

/* semantic pass progress */
static void print_name (char * dir_name, int len)
{
    int i;

    if (fsck_quiet (fs))
	return;
    printf("/");
    for (i = 0; i<len; i++, dir_name++)
        printf ("%c", *dir_name);
    fflush (stdout);
}

static void erase_name (int len)
{
    int i;

    if (fsck_quiet (fs))
	return;
    for (i = 0; i<=len; i++)
        printf("\b");
    for (i = 0; i<=len; i++)
        printf(" ");
    for (i = 0; i<=len; i++)
        printf("\b");
    fflush (stdout);
}


/* *size is "real" file size, sd_size - size from stat data */
static int wrong_st_size (struct key * key, loff_t max_file_size, int blocksize,
			  __u64 * size, __u64 sd_size)
{
    if (sd_size <= max_file_size) {
	if (sd_size == *size)
	    return 0;

	if (sd_size > *size) {
	    /* size in stat data can be bigger than size calculated by items */
	    if (fsck_fix_bogus_things (fs)) {
		/* but it -o is given - fix that */
		fsck_log ("file %K has too big file size sd_size %Ld - fixed to %Ld\n",
			  key, sd_size, *size);
		stats(fs)->fixed_sizes ++;
		return 1;
	    }
	    *size = sd_size;
	    return 0;
	}
	
	if (!(*size % blocksize)) {
	    /* last item is indirect */
	    if (((sd_size & ~(blocksize - 1)) == (*size - blocksize)) && sd_size % blocksize) {
		/* size in stat data is correct */
		*size = sd_size;
		return 0;
	    }
	} else {
	    /* last item is a direct one */
	    if (!(*size % 8)) {
		if (((sd_size & ~7) == (*size - 8)) && sd_size % 8) {
		    /* size in stat data is correct */
		    *size = sd_size;
		    return 0;
		}
	    }
	}
    }

    fsck_log ("file %K has wrong sd_size %Ld, has to be %Ld\n",
	      key, sd_size, *size);
    stats(fs)->fixed_sizes ++;
    return 1;
}


/* sd_blocks is 32 bit only */
static int wrong_st_blocks (struct key * key, __u32 blocks, __u32 sd_blocks)
{
    if (blocks == sd_blocks)
	return 0;

    fsck_log ("file %K has wrong sd_blocks %d, has to be %d\n",
	      key, sd_blocks, blocks);
    return 1;
}


/* only regular files and symlinks may have items but stat
   data. Symlink shold have body */
static int wrong_mode (struct key * key, mode_t * mode, __u64 real_size)
{
    if (!fsck_fix_bogus_things (fs))
	return 0;

    if (ftypelet (*mode) != '?') {
	/* mode looks reasonable */
	if (S_ISREG (*mode) || S_ISLNK (*mode))
	    return 0;
	
	/* device, pipe, socket have no items */
	if (!real_size)
	    return 0 ;
    }
    /* there are items, so change file mode to regular file. Otherwise
       - file bodies do not get deleted */
    fsck_log ("file %K (%M) has body, mode fixed to %M\n",
	      key, *mode, (S_IFREG | 0600));
    *mode = (S_IFREG | 0600);
    return 1;
}


/* key is a key of last file item */
static int wrong_first_direct_byte (struct key * key, int blocksize, 
				    __u32 * first_direct_byte,
				    __u32 sd_first_direct_byte, __u32 size)
{
    if (!size || is_indirect_key (key)) {
	/* there is no direct item */
	*first_direct_byte = NO_BYTES_IN_DIRECT_ITEM;
	if (sd_first_direct_byte != NO_BYTES_IN_DIRECT_ITEM) {
	    return 1;
	}
	return 0;
    }

    /* there is direct item */
    *first_direct_byte = (get_offset (key) & ~(blocksize - 1)) + 1;
    if (*first_direct_byte != sd_first_direct_byte) {
	fsck_log ("file %k has wrong first direct byte %d, has to be %d\n",
		  key, sd_first_direct_byte, *first_direct_byte);
	return 1;
    }
    return 0;
}


/* path is path to stat data */
static void check_regular_file (struct path * path, void * sd)
{
    int mark_items_reachable;
    struct key key, sd_key;
    __u64 real_size, min_size, saved_size;
    __u32 blocks, saved_blocks;
    struct buffer_head * bh = get_bh (path);/* contains stat data */
    struct item_head * ih = get_ih (path);/* stat data item */
    int fix_sd;
    mode_t mode;
    int symlnk = 0;


    /* are_file_items_correct will mark items as reached in not
       FSCK_CHECK mode */
    mark_items_reachable = ((fsck_mode (fs) == FSCK_CHECK) ? 0 : 1);

    if (ih_key_format (ih) == KEY_FORMAT_2)
    {
	struct stat_data * sd_v2 = sd;
	
	mode = le16_to_cpu (sd_v2->sd_mode);

	if (sd_v2->sd_nlink == 0) {

	    if (S_ISREG (mode)) {
		stats(fs)->regular_files ++;
	    } else if (S_ISLNK (mode)) {
		symlnk = 1;
		stats(fs)->symlinks ++;
	    } else {
		stats(fs)->others ++;
	    }
	    saved_size = le64_to_cpu (sd_v2->sd_size);
	    saved_blocks = le32_to_cpu (sd_v2->sd_blocks);
	
	    if (fsck_mode (fs) != FSCK_CHECK) {
                sd_v2->sd_nlink = cpu_to_le32 (1);
	        mark_item_reachable (ih, bh);
            } else {
                if (!is_objectid_used (fs, ih->ih_key.k_objectid))
		    reiserfs_panic ("check_regular_file: unused objectid found %K\n", &ih->ih_key);
            }

	    /* ih's key is stat data key */
	    copy_key (&key, &(ih->ih_key));
	    copy_key (&sd_key, &key);

	    pathrelse (path);

	    if (are_file_items_correct (&key, KEY_FORMAT_2, &real_size, &min_size, &blocks,
					mark_items_reachable,
					symlnk, saved_size) != 1) {
		/* unpassed items will be deleted in pass 4 as they left unaccessed */
		stats(fs)->broken_files ++;
	    }

	    /* we know what should be sd_size, sd_blocks and sd_first_direct_byte */
	    fix_sd = 0;
	    fix_sd += wrong_st_size (&sd_key, MAX_FILE_SIZE_V2, 
				     fs->s_blocksize, &real_size, saved_size);
	    fix_sd += wrong_st_blocks (&sd_key, blocks, saved_blocks);
	    fix_sd += wrong_mode (&sd_key, &mode, real_size);

	    if (fix_sd && fsck_mode (fs) == FSCK_REBUILD) {
		/* find stat data and correct it */
		if (usearch_by_key (fs, &sd_key, path) != ITEM_FOUND)
		    die ("check_regular_file: stat data not found");

		bh= get_bh (path);
		sd_v2 = (struct stat_data *)B_I_PITEM (bh, get_ih (path));
		sd_v2->sd_size = cpu_to_le64 (real_size);
		sd_v2->sd_blocks = cpu_to_le32 (blocks);
		sd_v2->sd_mode = cpu_to_le16 (mode);
		mark_buffer_dirty (bh);
	    }
	} else {
	    /* one more link found. FIXME: we do not check number of links in
               check mode */
	    if (!is_item_reachable (ih))
		die ("check_regular_file: new stat data item must be accessed already");
	    if (fsck_mode (fs) == FSCK_REBUILD) {
		sd_v2->sd_nlink = cpu_to_le32 (le32_to_cpu (sd_v2->sd_nlink) + 1);
		mark_buffer_dirty (bh);
	    }
	}
    } else {
	struct stat_data_v1 * sd_v1 = sd;
	__u32 first_direct_byte, sd_first_direct_byte;

	mode = le16_to_cpu (sd_v1->sd_mode);

	if (sd_v1->sd_nlink == 0) {

	    /* save fields which will be checked */
	    saved_size = le32_to_cpu (sd_v1->sd_size);
	    saved_blocks = le32_to_cpu (sd_v1->u.sd_blocks);
	    sd_first_direct_byte = le32_to_cpu (sd_v1->sd_first_direct_byte);

	    if (S_ISREG (mode)) {
		stats(fs)->regular_files ++;
	    } else if (S_ISLNK (mode)) {
		stats(fs)->symlinks ++;
		symlnk = 1;
	    } else {
		stats(fs)->others ++;
	    }

	    if (fsck_mode (fs) != FSCK_CHECK) {
	        sd_v1->sd_nlink = cpu_to_le16 (1);
	        mark_item_reachable (ih, bh);
            } else {
                if (!is_objectid_used (fs, ih->ih_key.k_objectid))
		    reiserfs_panic("check_regular_file: unused objectid found %k\n", &ih->ih_key);
            }

	    /* ih's key is stat data key */
	    copy_key (&key, &(ih->ih_key));
	    copy_key (&sd_key, &key);

	    pathrelse (path);

	    if (are_file_items_correct (&key, ih_key_format (ih), &real_size, &min_size, &blocks,
					mark_items_reachable,
					symlnk, sd_v1->sd_size) != 1) {
		/* unpassed items will be deleted in pass 4 as they left unaccessed */
		stats(fs)->broken_files ++;
	    }

	    /* we know what should be sd_size, sd_blocks and sd_first_direct_byte */
	    fix_sd = 0;
	    fix_sd += wrong_mode (&key, &mode, real_size);
	    fix_sd += wrong_first_direct_byte (&key, fs->s_blocksize,
					       &first_direct_byte, sd_first_direct_byte, real_size);
	    fix_sd += wrong_st_size (&sd_key, MAX_FILE_SIZE_V1, 
				     fs->s_blocksize, &real_size, saved_size);
	    if (S_ISDIR (mode) || S_ISREG (mode) || S_ISLNK (mode))
		/* old stat data shares sd_block and sd_dev. We do not
                   want to wipe put sd_dev for device files */
		fix_sd += wrong_st_blocks (&sd_key, blocks, saved_blocks);

	    if (fix_sd && fsck_mode (fs) == FSCK_REBUILD) {
		if (usearch_by_key (fs, &sd_key, path) != ITEM_FOUND)
		    die ("check_regular_file: stat data not found");

		bh = get_bh (path);
		sd_v1 = (struct stat_data_v1 *)B_I_PITEM (bh, get_ih (path));
		sd_v1->sd_size = cpu_to_le32 (real_size);
		sd_v1->u.sd_blocks = cpu_to_le32 (blocks);
		sd_v1->sd_first_direct_byte = cpu_to_le32 (first_direct_byte);
		sd_v1->sd_mode = cpu_to_le16 (mode);
		mark_buffer_dirty (bh);
	    }
	} else {
	    /* one more link found. FIXME: we do not check number of links in
               check mode */
	    if (!is_item_reachable (ih))
		die ("check_regular_file: old stat data item %H must be accessed already", ih);
	    if (fsck_mode (fs) == FSCK_REBUILD) {
		sd_v1->sd_nlink = cpu_to_le16 (le16_to_cpu (sd_v1->sd_nlink) + 1);
		mark_buffer_dirty (bh);
	    }
	}
    }
}


static int is_rootdir_key (struct key * key)
{
    if (comp_keys (key, &root_dir_key))
	return 0;
    return 1;
}


/* returns buffer, containing found directory item.*/
static char * get_next_directory_item (struct path * path, struct key * key,
				       struct key * parent,
				       struct item_head * ih,
				       int lost_found)
{
    char * dir_item;
    struct key * rdkey;
    struct buffer_head * bh;
    struct reiserfs_de_head * deh;
    int i;
    int retval;


    if ((retval = usearch_by_entry_key (fs, key, path)) != POSITION_FOUND) {
	if (get_offset (key) != DOT_OFFSET)
	    /* we always search for existing key, but "." */
	    die ("get_next_directory_item: %k is not found", key);
	
	pathrelse (path);

	if (fsck_mode (fs) == FSCK_CHECK) {
	    fsck_log ("get_next_directory_item: directory has no \".\" entry %k\n",
		      key);
	    pathrelse (path);
	    return 0;
	}

 	fsck_log ("making \".\" and/or \"..\" for %K\n", key);
	reiserfs_add_entry (fs, key, ".", key, 1 << IH_Unreachable, 0/*not lost&found*/);
	reiserfs_add_entry (fs, key, "..", parent, 1 << IH_Unreachable, 0);


	/* we have fixed a directory, search its first item again */
	usearch_by_entry_key (fs, key, path);
    }

    /* leaf containing directory item */
    bh = PATH_PLAST_BUFFER (path);

    memcpy (ih, PATH_PITEM_HEAD (path), IH_SIZE);

    /* make sure, that ".." exists as well */
    if (get_offset (key) == DOT_OFFSET) {
	if (ih_entry_count (ih) < 2) {
	    pathrelse (path);
	    return 0;
	}
	deh = B_I_DEH (bh, ih) + 1;
	if (name_length (ih, deh, 1) != 2 ||
	    name_in_entry (deh, 1)[0] != '.' || name_in_entry (deh, 1)[1] != '.') {
	    fsck_log ("get_next_directory_item: \"..\" not found in %H\n", ih);
	    pathrelse (path);
	    return 0;
	}
    }

    deh = B_I_DEH (bh, ih);

    /* mark hidden entries as visible, reset ".." correctly */
    for (i = 0; i < ih_entry_count (ih); i ++, deh ++) {
	int namelen;
	char * name;

	name = name_in_entry (deh, i);
	namelen = name_length (ih, deh, i);
	if (de_hidden (deh))
	{
	    fsck_log ("get_next_directory_item: item %k: hidden entry %d \'%.*s\'\n",
		      key, i, namelen, name);

	    if (fsck_mode (fs) != FSCK_CHECK) {
		mark_de_visible (deh);
		mark_buffer_dirty (bh);
	    }
	}
	
	if (deh->deh_offset == DOT_OFFSET)
	{
	    if (comp_short_keys (&(deh->deh_dir_id), key) &&
		deh->deh_objectid != REISERFS_ROOT_PARENT_OBJECTID)/*????*/
            {
		fsck_log ("get_next_directory_item: wrong \".\" found %k\n", key);
                if (fsck_mode (fs) == FSCK_REBUILD) {
		    deh->deh_dir_id = key->k_dir_id;
		    deh->deh_objectid = key->k_objectid;
		    mark_buffer_dirty (bh);
		}
	    }
	}
	
	if (deh->deh_offset == DOT_DOT_OFFSET)
	{
	    /* set ".." so that it points to the correct parent directory */
	    if (comp_short_keys (&(deh->deh_dir_id), parent) &&
		deh->deh_objectid != REISERFS_ROOT_PARENT_OBJECTID)/*???*/
            {
		/* suppress this warning on lost+found pass */
		if (!lost_found)
		    fsck_log ("get_next_directory_item: %k: \"..\" pointed to [%K], "
			      "fixed to [%K]\n",
			      key, (struct key *)(&(deh->deh_dir_id)), parent);
		if (fsck_mode (fs) == FSCK_REBUILD) {
		    deh->deh_dir_id = parent->k_dir_id;
		    deh->deh_objectid = parent->k_objectid;
		    mark_buffer_dirty (bh);
		}
	    }
	}
    }

    /* copy directory item to the temporary buffer */
    dir_item = getmem (ih_item_len (ih)); 
    memcpy (dir_item, B_I_PITEM (bh, ih), ih_item_len (ih));

    /* unmark entries marked DEH_Lost_Found */
    deh = B_I_DEH (bh, ih);
    for (i = 0; i < ih_entry_count (ih); i ++, deh ++) {
	if (de_lost_found (deh)) {
	    if (fsck_mode (fs) == FSCK_CHECK) {
		if (fsck_fix_fixable (fs))
		    reiserfs_panic ("block %lu: item %H: %d entry %.*s marked lost+found found",
				    bh->b_blocknr, ih, i, name_length (ih, deh, i),
				    name_in_entry (deh, i));
	    } else {
		unmark_de_lost_found (deh);
		mark_buffer_dirty (bh);
	    }
	}
    }    


    /* next item key */
    if (PATH_LAST_POSITION (path) == (B_NR_ITEMS (PATH_PLAST_BUFFER (path)) - 1) &&
	(rdkey = uget_rkey (path)))
	copy_key (key, rdkey);
    else {
	key->k_dir_id = 0;
	key->k_objectid = 0;
    }

    if (fsck_mode (fs) != FSCK_CHECK)
        mark_item_reachable (PATH_PITEM_HEAD (path), PATH_PLAST_BUFFER (path));
    return dir_item;
}


// get key of an object pointed by direntry and the key of the entry itself
static void get_object_key (struct reiserfs_de_head * deh, struct key * key, 
			    struct key * entry_key, struct item_head * ih)
{
    key->k_dir_id = deh->deh_dir_id;
    key->k_objectid = deh->deh_objectid;
    key->u.k_offset_v1.k_offset = SD_OFFSET;
    key->u.k_offset_v1.k_uniqueness = V1_SD_UNIQUENESS;

    entry_key->k_dir_id = ih->ih_key.k_dir_id;
    entry_key->k_objectid = ih->ih_key.k_objectid;
    entry_key->u.k_offset_v1.k_offset = deh->deh_offset;
    entry_key->u.k_offset_v1.k_uniqueness = DIRENTRY_UNIQUENESS;
}


static void reiserfsck_cut_entry (struct key * key)
{
    INITIALIZE_PATH (path);
    struct item_head * ih;

    if (usearch_by_entry_key (fs, key, &path) != POSITION_FOUND || get_offset (key) == DOT_OFFSET)
	die ("reiserfsck_cut_entry: entry not found");

    ih = get_ih (&path);
    if (ih_entry_count (ih) == 1)
	reiserfsck_delete_item (&path, 0);
    else {
	struct reiserfs_de_head * deh = B_I_DEH (get_bh (&path), ih) + path.pos_in_item;

	reiserfsck_cut_from_item (&path, -(DEH_SIZE + entry_length (ih, deh, path.pos_in_item)));
    }
}



/* check recursively the semantic tree. Returns 0 if entry points to
   good object, and -1 or -2 if this entry must be deleted (stat data
   not found or directory does have any items).  Hard links are not
   allowed, but if directory rename has been interrupted by the system
   crash, it is possible, that fsck will find two entries (not "..") 
   pointing to the same directory. In this case fsck keeps only the
   first one. */
#define OK 0
#define STAT_DATA_NOT_FOUND -1
#define DIRECTORY_HAS_NO_ITEMS -2



// FIXME: hash can be detected wrong when two hash functions give the
// same value on the first name which gets here
//
static void detect_check_and_set_hash (reiserfs_filsys_t fs, char * name, int namelen,
				       __u32 deh_offset)
{
    if (!is_properly_hashed (fs, name, namelen, deh_offset)) {
	if (fsck_mode (fs) == FSCK_CHECK)
	    fsck_log ("check_semantic_tree: hash mismatch detected (%.*s)\n", namelen, name);
	else
	    reiserfs_panic ("check_semantic_tree: name %.*s has to be hashed properly",
			    namelen, name);
    }
}



/* this can be called to scan either whole filesystem tree or lost+found
   only. In later case - it has to not skip reading of a directory if its
   sd_nlink is not 0 already and proceed only new names created by lost+found
   pass (they are marked "DEH_Found") */
int check_semantic_tree (struct key * key, struct key * parent, int is_dot_dot, int lost_found)
{
    struct path path;
    void * sd;
    int version;
    __u32 nlink;
    struct buffer_head * bh;
    struct item_head * ih;


    if (!KEY_IS_STAT_DATA_KEY (key))
	die ("check_semantic_tree: key must be key of a stat data");

    /* look for stat data of an object */
    if (usearch_by_key (fs, key, &path) == ITEM_NOT_FOUND) {
	pathrelse (&path);
	if (fsck_mode (fs) != FSCK_CHECK && is_rootdir_key (key))
	    /* root directory has to exist at this point */
	    reiserfs_panic ("check_semantic_tree: root directory not found");

	return STAT_DATA_NOT_FOUND;
    }

    /* stat data has been found */
    version = ih_key_format (get_ih (&path));
    sd = get_item(&path);

    if (version == KEY_FORMAT_2)
    {
	struct stat_data * sd_v2 = sd;

        if ((sd_v2->sd_nlink == 0) && (fsck_mode (fs) == FSCK_CHECK))
            fsck_log ("check_semantic_tree: sd_nlink is 0 of %k\n", &(get_ih(&path)->ih_key));
	
	if ( !S_ISDIR (sd_v2->sd_mode) )
	{
	    /* object is not a directory (regular, symlink, device file) */
	    check_regular_file (&path, sd);
	    pathrelse (&path);
	    return OK;
	}

	if (fsck_mode (fs) != FSCK_CHECK)
	{
	    if (!lost_found) {
		/* we found one more link to a directory, adjust sd_nlink */
		nlink = le32_to_cpu (sd_v2->sd_nlink) + 1;
		sd_v2->sd_nlink = cpu_to_le32 (nlink +
					       ((key->k_objectid == REISERFS_ROOT_OBJECTID && nlink == 1) ? 1 : 0));
	    } else {
		/* we are going to scan /lost+found for new names only */
		nlink = 1;
	    }
	} else {
	    nlink = 1;
	}
    }
    else
    {
	struct stat_data_v1 * sd_v1 = sd;
	
        if ((sd_v1->sd_nlink == 0) && (fsck_mode (fs) == FSCK_CHECK))
            reiserfs_panic("check_semantic_tree: sd_nlink is 0 %k\n", &(get_ih(&path)->ih_key));
	
	if (!S_ISDIR (sd_v1->sd_mode))
	{
	    /* object is not a directory (regular, symlink, device file) */
	    check_regular_file (&path, sd);
	    pathrelse (&path);
	    return OK;
	}

	if (fsck_mode (fs) != FSCK_CHECK)
	{
	    if (!lost_found) {
		/* we found one more link to a directory, adjust sd_nlink */
		nlink = le16_to_cpu (sd_v1->sd_nlink) + 1;
		sd_v1->sd_nlink = cpu_to_le16 (nlink +
					       ((key->k_objectid == REISERFS_ROOT_OBJECTID && nlink == 1) ? 1 : 0));
	    } else {
		/* we are going to scan /lost+found for new names only */
		nlink = 1;
	    }
        } else {
	    nlink = 1;
	}
    }

    if (fsck_mode (fs) != FSCK_CHECK)
        mark_buffer_dirty (PATH_PLAST_BUFFER (&path));

    /* object is directory */
    if (nlink == 1 || fsck_mode (fs) == FSCK_CHECK || lost_found) {
	char * dir_item;
	struct item_head tmp_ih;
	struct key item_key, entry_key, object_key;
	__u64 dir_size = 0;
        __u32 blocks;


	stats(fs)->directories ++;
	copy_key (&item_key, key);
	item_key.u.k_offset_v1.k_offset = DOT_OFFSET;
	item_key.u.k_offset_v1.k_uniqueness = DIRENTRY_UNIQUENESS;
	pathrelse (&path);

	while ((dir_item = get_next_directory_item (&path, &item_key, parent, &tmp_ih, lost_found)) != 0) {
	    /* dir_item is copy of the item in separately allocated memory */
	    int i;
	    int retval;
	    struct reiserfs_de_head * deh = (struct reiserfs_de_head *)dir_item + path.pos_in_item;

/*&&&&&&&&&&&&&&&*/
	    if (dir_size == 0) {
		if (deh->deh_offset != DOT_OFFSET || (deh + 1)->deh_offset != DOT_DOT_OFFSET)
		    die ("check_semantic_tree: Directory without \".\" or \"..\"");
	    }
/*&&&&&&&&&&&&&&&*/

	    for (i = path.pos_in_item; i < ih_entry_count (&tmp_ih); i ++, deh ++) {
		char * name;
		int namelen;

		name = name_in_entry (deh, i);
		namelen = name_length (&tmp_ih, deh, i);

		print_name (name, namelen);

		detect_check_and_set_hash (fs, name, namelen, deh_offset (deh));

		get_object_key (deh, &object_key, &entry_key, &tmp_ih);
		if (fsck_mode (fs) != FSCK_CHECK) {
		    if (!lost_found || de_lost_found (deh)) {
			/* check entry if we are not in lost+found pass or
                           this name was added on lost+found pass */
			retval = check_semantic_tree (&object_key, key,
						      (deh->deh_offset == DOT_OFFSET ||
						       deh->deh_offset == DOT_DOT_OFFSET) ? 1 : 0,
						      0);
		    } else {
			/* this is old entry in /lost+found directory */
			retval = OK;
		    }
		} else {
		    /* --check: do not go by "." and ".." */
		    if (deh->deh_offset != DOT_OFFSET && deh->deh_offset != DOT_DOT_OFFSET)
		    {
		        add_path_key(&object_key);
                        retval = check_semantic_tree (&object_key, key, 0, 0/* do not skip "lost+found" */);
		        del_path_key();
                    } else
                        retval = OK;
		}

		erase_name (namelen);

		if (retval != OK) {
		    /* stat data not found */
		    if (fsck_mode (fs) == FSCK_CHECK) {
                        fsck_log ("check_semantic_tree: name \"%.*s\" in directory %K points to nowhere",
				  namelen, name, &tmp_ih.ih_key);
			if (fsck_fix_fixable (fs)) {
			    reiserfs_remove_entry (fs, &entry_key);
			    fsck_log (" - fixed");
			}
			fsck_log ("\n");
		    } else {
			if (get_offset (&entry_key) == DOT_DOT_OFFSET && object_key.k_objectid == REISERFS_ROOT_PARENT_OBJECTID) {
			    /* ".." of root directory can not be found */
			    if (retval != STAT_DATA_NOT_FOUND)
				die ("check_semantic_tree: stat data of parent directory of root directory found");
			    dir_size += DEH_SIZE + ((version == KEY_FORMAT_2) ? ROUND_UP (strlen ("..")) : strlen (".."));
			    continue;
			}
			stats(fs)->deleted_entries ++;
			reiserfsck_cut_entry (&entry_key);
		    }
		} else {
		    /* OK */
                    dir_size += DEH_SIZE + entry_length (&tmp_ih, deh, i);
		}
	    }

	    freemem (dir_item);

	    if (not_of_one_file (&item_key, key)) {
		pathrelse (&path);
		break;
	    }
	    pathrelse (&path);
	}

	if (dir_size == 0)
	    /* FIXME: is it possible? */
	    return DIRECTORY_HAS_NO_ITEMS;

	/* calc correct value of sd_blocks field of stat data */
	blocks = dir_size2st_blocks (fs->s_blocksize, dir_size);


	/* look for directory stat data again */
	if (usearch_by_key (fs, key, &path) != ITEM_FOUND)
	    die ("check_semantic_tree: stat data not found");

        sd = get_item (&path);
	bh = get_bh (&path);
	ih = get_ih (&path);

	if (fsck_mode (fs) == FSCK_CHECK) {
	    /* make sure that objectid is marked used in the super block
               objectid map */
	    if (!is_objectid_used (fs, ih->ih_key.k_objectid))
		fsck_log ("check_semantic_tree: objectid %d is unused\n",
			  ih->ih_key.k_objectid);
	}

        if (version == KEY_FORMAT_2)
        {
	    struct stat_data * sd_v2 = sd;

	    if (dir_size != le64_to_cpu (sd_v2->sd_size)) {
		if (fsck_mode (fs) == FSCK_CHECK) {
		    /* --check */
	            fsck_log ("check_semantic_tree: "
			      "new dir %K has sd_size %Ld mismatching to the right one %Ld",
			      &ih->ih_key, le64_to_cpu (sd_v2->sd_size), dir_size);
		    if (fsck_fix_fixable (fs)) {
			/* --check && --fix-fixable */
			sd_v2->sd_size = cpu_to_le64 (dir_size);
			mark_buffer_dirty (bh);
			fsck_log (" - fixed");
		    }
		    fsck_log ("\n");
		} else {
		    /* --rebuild-tree */
		    sd_v2->sd_size = cpu_to_le64 (dir_size);
		    mark_buffer_dirty (bh);
		}
	    }

	    if (blocks != _ROUND_UP (le32_to_cpu (sd_v2->sd_blocks), fs->s_blocksize / 512))
	    {
	        if (fsck_mode (fs) == FSCK_CHECK) {
		    /* --check */
	            fsck_log ("check_semantic_tree: new dir %K has st_block mismatch "
			      "(found %d, in stat data %d)", &ih->ih_key,
			      blocks, le32_to_cpu (sd_v2->sd_blocks));
		    if (fsck_fix_fixable (fs)) {
			/* --check && --fix-fixable */
			sd_v2->sd_blocks = cpu_to_le32 (blocks);
			mark_buffer_dirty (bh);
			fsck_log (" - fixed");
		    }
		    fsck_log ("\n");
		} else {
		    /* --rebuild-tree */
		    sd_v2->sd_blocks = cpu_to_le32 (blocks);
		    mark_buffer_dirty (bh);
		}
	    }
        }
	else
	{
	    struct stat_data_v1 * sd_v1 = sd;

	    if (dir_size != le32_to_cpu (sd_v1->sd_size))
	    {
	        if (fsck_mode (fs) == FSCK_CHECK) {
		    /* --check */
	            fsck_log ("check_semantic_tree: "
			      "old dir %k has sd_size %d mismatching to the right one %Ld",
			      &ih->ih_key, le32_to_cpu (sd_v1->sd_size), dir_size);
		    if (fsck_fix_fixable (fs)) {
			/* --check && --fix-fixable */
			sd_v1->sd_size = cpu_to_le32 (dir_size);
			mark_buffer_dirty (bh);
			fsck_log (" - fixed");
		    }
		    fsck_log ("\n");
		} else {
		    /* --rebuild-tree */
		    sd_v1->sd_size = cpu_to_le32 (dir_size);
		    mark_buffer_dirty (bh);
		}
	    }

	    if (blocks != _ROUND_UP (le32_to_cpu (sd_v1->u.sd_blocks), fs->s_blocksize / 512))
	    {
	        if (fsck_mode (fs) == FSCK_CHECK) {
		    /* --check */
	            fsck_log ("check_semantic_tree: old dir %K has st_block mismatch "
			      "(found %d, in stat data %d)", &ih->ih_key,
			      blocks, le32_to_cpu (sd_v1->u.sd_blocks));
		    if (fsck_fix_fixable (fs)) {
			/* --check && --fix-fixable */
			sd_v1->u.sd_blocks = cpu_to_le32(blocks);
			mark_buffer_dirty (bh);
			fsck_log (" - fixed");
		    }
		    fsck_log ("\n");
		} else {
		    /* --rebuild-tree */
		    sd_v1->u.sd_blocks = cpu_to_le32(blocks);	
		    mark_buffer_dirty (bh);
		}
	    }
        }

	/* stat data of a directory is accessed */
	if (fsck_mode (fs) != FSCK_CHECK)
	    mark_item_reachable (ih, bh);
    } else {
	/* we have accessed directory stat data not for the first time. we
	   can come here only from "." or "..". Other names must be removed
	   to avoid creation of hard links */
	if (fsck_mode (fs) == FSCK_CHECK)
            die ("check_semantic_tree: can not get here");
	
	if (!is_dot_dot) {
	    if (version == KEY_FORMAT_2)
	    {
		struct stat_data * sd_v2 = sd;

		nlink = le32_to_cpu (sd_v2->sd_nlink);
		sd_v2->sd_nlink = cpu_to_le32 (nlink - 1);
	    }
	    else
	    {
		struct stat_data_v1 * sd_v1 = sd;

		nlink = le16_to_cpu (sd_v1->sd_nlink);
		sd_v1->sd_nlink = cpu_to_le16 (nlink - 1);
	    }

	    fsck_log ("\ncheck_semantic_tree: more than one name "
		      "(neither \".\" nor \"..\") of a directory. Removed\n");
	    pathrelse (&path);
	    return STAT_DATA_NOT_FOUND;
	}
    }
    pathrelse (&path);

    return OK;
}

int is_dot (char * name, int namelen)
{
    return (namelen == 1 && name[0] == '.') ? 1 : 0;
}


int is_dot_dot (char * name, int namelen)
{
    return (namelen == 2 && name[0] == '.' && name[1] == '.') ? 1 : 0;
}


int not_a_directory (void * sd)
{
    /* mode is at the same place and of the same size in both stat
       datas (v1 and v2) */
    struct stat_data_v1 * sd_v1 = sd;

    return !(S_ISDIR (le16_to_cpu (sd_v1->sd_mode)));
}


void zero_nlink (struct item_head * ih, void * sd)
{
    if (ih_item_len (ih) == SD_V1_SIZE && ih_key_format (ih) != KEY_FORMAT_1) {
	fsck_log ("zero_nlink: %H had wrong keys format %d, fixed to %d",
		  ih, ih_key_format (ih), KEY_FORMAT_1);
	set_key_format (ih, KEY_FORMAT_1);
    }
    if (ih_item_len (ih) == SD_SIZE && ih_key_format (ih) != KEY_FORMAT_2) {
	fsck_log ("zero_nlink: %H had wrong keys format %d, fixed to %d",
		  ih, ih_key_format (ih), KEY_FORMAT_2);
	set_key_format (ih, KEY_FORMAT_2);
    }

    if (ih_key_format (ih) == KEY_FORMAT_1) {
	struct stat_data_v1 * sd_v1 = sd;

	sd_v1->sd_nlink = 0;
    } else {
	struct stat_data * sd_v2 = sd;

	sd_v2->sd_nlink = 0;
    }
}


/* inserts new or old stat data of a directory (unreachable, nlinks == 0) */
void create_dir_sd (reiserfs_filsys_t fs, 
		    struct path * path, struct key * key)
{
    struct item_head ih;
    struct stat_data sd;
    int key_format;

    if (SB_VERSION(fs) == REISERFS_VERSION_2)
	key_format = KEY_FORMAT_2;
    else
	key_format = KEY_FORMAT_1;

    make_dir_stat_data (fs->s_blocksize, key_format, key->k_dir_id,
			key->k_objectid, &ih, &sd);

    /* set nlink count to 0 and make the item unreachable */
    zero_nlink (&ih, &sd);
    mark_item_unreachable (&ih);

    reiserfs_insert_item (fs, path, &ih, &sd);
}


static void make_sure_root_dir_exists (reiserfs_filsys_t fs)
{
    INITIALIZE_PATH (path);

    /* is there root's stat data */
    if (usearch_by_key (fs, &root_dir_key, &path) == ITEM_NOT_FOUND) {	
	create_dir_sd (fs, &path, &root_dir_key);
	mark_objectid_really_used (proper_id_map (fs), REISERFS_ROOT_OBJECTID);
    } else
	pathrelse (&path);

    /* add "." and ".." if any of them do not exist. Last two
       parameters say: 0 - entry is not added on lost_found pass and 1
       - mark item unreachable */
    reiserfs_add_entry (fs, &root_dir_key, ".", &root_dir_key, 
			1 << IH_Unreachable, 0/*not lost&found*/);
    reiserfs_add_entry (fs, &root_dir_key, "..", &parent_root_dir_key, 
			1 << IH_Unreachable, 0);
}


/* mkreiserfs should have created this */
static void make_sure_lost_found_exists (reiserfs_filsys_t fs)
{
    int retval;
    INITIALIZE_PATH (path);
    int gen_counter;

    /* look for "lost+found" in the root directory */
    lost_found_dir_key.k_objectid = reiserfs_find_entry (fs, &root_dir_key,
							 "lost+found", &gen_counter);
    if (!lost_found_dir_key.k_objectid) {
	lost_found_dir_key.k_objectid = get_unused_objectid (fs);
	if (!lost_found_dir_key.k_objectid) {
	    fsck_progress ("make_sure_lost_found_exists: could not get objectid"
			   " for \"/lost+found\", will not link lost files\n");
	    return;
	}
    }

    /* look for stat data of "lost+found" */
    retval = usearch_by_key (fs, &lost_found_dir_key, &path);
    if (retval == ITEM_NOT_FOUND)
	create_dir_sd (fs, &path, &lost_found_dir_key);
    else {
	if (not_a_directory (get_item (&path))) {
	    fsck_progress ("make_sure_lost_found_exists: \"/lost+found\" is "
			   "not a directory, will not link lost files\n");
	    lost_found_dir_key.k_objectid = 0;
	    pathrelse (&path);
	    return;
	}
	pathrelse (&path);
    }

    /* add "." and ".." if any of them do not exist */
    reiserfs_add_entry (fs, &lost_found_dir_key, ".", &lost_found_dir_key,
			1 << IH_Unreachable, 0/*not lost&found*/);
    reiserfs_add_entry (fs, &lost_found_dir_key, "..", &root_dir_key, 
			1 << IH_Unreachable, 0);

    reiserfs_add_entry (fs, &root_dir_key, "lost+found", &lost_found_dir_key, 
			1 << IH_Unreachable, 0);

    return;
}


/* this is part of rebuild tree */
void pass_3_semantic (void)
{
    fsck_progress ("Pass 3 (semantic):\n");

    /* when warnings go not to stderr - separate then in the log */
    if (fsck_log_file (fs) != stderr)
	fsck_log ("####### Pass 3 #########\n");
    

    make_sure_root_dir_exists (fs);
    make_sure_lost_found_exists (fs);

    /* link all files remapped into root directory */
    link_remapped_files ();

    if (check_semantic_tree (&root_dir_key, &parent_root_dir_key, 0, 0/*not lost+found*/) != OK)
        die ("check_semantic_tree: bad root found");

    stage_report (3, fs);

//    free_objectid_maps();
}


/* called when --check is given */
void semantic_check (void)
{
    fsck_progress ("Checking Semantic tree...");

//    init_objectid_list();

    if (check_semantic_tree (&root_dir_key, &parent_root_dir_key, 0, 0/*not lost+found yet*/) != OK)
        die ("check_semantic_tree: bad root found");

//    free_objectid_maps();

    fsck_progress ("ok\n");

}
