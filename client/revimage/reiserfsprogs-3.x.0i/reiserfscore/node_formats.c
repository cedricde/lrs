/*
 *  Copyright 2000 by Hans Reiser, licensing governed by reiserfs/README
 */


#include "includes.h"



/* this only checks that the node looks like a correct leaf. Item
   internals are not checked */
static int is_correct_leaf (char * buf, int blocksize)
{
    struct block_head * blkh;
    struct item_head * ih;
    int used_space;
    int prev_location;
    int i;
    int nr;

    blkh = (struct block_head *)buf;
    if (!is_leaf_block_head (buf))
	return 0;

    nr = le16_to_cpu (blkh->blk_nr_item);
    if (nr < 1 || nr > ((blocksize - BLKH_SIZE) / (IH_SIZE + MIN_ITEM_LEN)))
	/* item number is too big or too small */
	return 0;

    ih = (struct item_head *)(buf + BLKH_SIZE) + nr - 1;
    used_space = BLKH_SIZE + IH_SIZE * nr + (blocksize - ih_location (ih));
    if (used_space != blocksize - le16_to_cpu (blkh->blk_free_space))
	/* free space does not match to calculated amount of use space */
	return 0;

    // FIXME: it is_leaf will hit performance too much - we may have
    // return 1 here

    /* check tables of item heads */
    ih = (struct item_head *)(buf + BLKH_SIZE);
    prev_location = blocksize;
    for (i = 0; i < nr; i ++, ih ++) {
	/* items of length are allowed - they may exist for short time
           during balancing */
	if (ih_location (ih) > blocksize || ih_location (ih) < IH_SIZE * nr)
	    return 0;
	if (/*ih_item_len (ih) < 1 ||*/ ih_item_len (ih) > MAX_ITEM_LEN (blocksize))
	    return 0;
	if (prev_location - ih_location (ih) != ih_item_len (ih))
	    return 0;
	prev_location = ih_location (ih);
    }

    // one may imagine much more checks
    return 1;
}


/* returns 1 if buf looks like an internal node, 0 otherwise */
static int is_correct_internal (char * buf, int blocksize)
{
    struct block_head * blkh;
    int nr;
    int used_space;

    blkh = (struct block_head *)buf;

    if (!is_internal_block_head (buf))
	return 0;
    
    nr = le16_to_cpu (blkh->blk_nr_item);
    if (nr > (blocksize - BLKH_SIZE - DC_SIZE) / (KEY_SIZE + DC_SIZE))
	/* for internal which is not root we might check min number of keys */
	return 0;

    used_space = BLKH_SIZE + KEY_SIZE * nr + DC_SIZE * (nr + 1);
    if (used_space != blocksize - le16_to_cpu (blkh->blk_free_space))
	return 0;

    // one may imagine much more checks
    return 1;
}


// make sure that bh contains formatted node of reiserfs tree of
// 'level'-th level
int is_tree_node (struct buffer_head * bh, int level)
{
    if (B_LEVEL (bh) != level)
	return 0;
    if (is_leaf_node (bh))
	return is_correct_leaf (bh->b_data, bh->b_size);

    return is_correct_internal (bh->b_data, bh->b_size);
}


static int is_desc_block (struct reiserfs_journal_desc * desc)
{
    if (!memcmp(desc->j_magic, JOURNAL_DESC_MAGIC, 8) &&
	le32_to_cpu (desc->j_len) > 0)
	return 1;
    return 0;
}



/* returns code of reiserfs metadata block (leaf, internal, super
   block, journal descriptor), unformatted */
int who_is_this (char * buf, int blocksize)
{
    if (is_correct_leaf (buf, blocksize))
	/* block head and item head array seem matching (node level, free
           space, item number, item locations and length) */
	return THE_LEAF;

    if (is_correct_internal (buf, blocksize))
	return THE_INTERNAL;

    /* super block? */
    if (is_reiser2fs_magic_string ((void *)buf) || 
	is_reiserfs_magic_string ((void *)buf) ||
	is_prejournaled_reiserfs ((void *)buf))
	return THE_SUPER;

    /* journal descriptor block? */
    if (is_desc_block ((void *)buf))
	return THE_JDESC;

    /* contents of buf does not look like reiserfs metadata. Bitmaps
       are possible here */
    return THE_UNKNOWN;
}


int block_of_journal (reiserfs_filsys_t fs, unsigned long block)
{
    if (block >= SB_JOURNAL_BLOCK (fs) && 
	block <= SB_JOURNAL_BLOCK (fs) + JOURNAL_BLOCK_COUNT)
	return 1;

    return 0;
}


int block_of_bitmap (reiserfs_filsys_t fs, unsigned long block)
{
    if (spread_bitmaps (fs)) {
	if (!(block % (fs->s_blocksize * 8)))
	    /* bitmap block */
	    return 1;
	return block == 17;
    } else {
	/* bitmap in */
	if (block > 2 && block < 3 + SB_BMAP_NR (fs))
	    return 1;
	return 0;
    }
#if 0
    int i;
    int bmap_nr;

    bmap_nr = SB_BMAP_NR (fs);
    for (i = 0; i < bmap_nr; i ++)
	if (block == SB_AP_BITMAP (fs)[i]->b_blocknr)
	    return 1;
#endif
    return 0;
}


/* check whether 'block' can be pointed to by an indirect item */
int not_data_block (reiserfs_filsys_t fs, unsigned long block)
{
    if (block <= fs->s_sbh->b_blocknr)
	/* either super block or a block from skipped area at the
           beginning of filesystem */
	return 1;

    if (block_of_journal (fs, block))
	/* block of journal area */
	return 1;

    if (block_of_bitmap (fs, block))
	/* it is one of bitmap blocks */
	return 1;
    
    return 0;
}


/* check whether 'block' can be logged */
int not_journalable (reiserfs_filsys_t fs, unsigned long block)
{
    if (block < fs->s_sbh->b_blocknr)
	return 1;

    if (block_of_journal (fs, block))
	return 1;

    if (block >= SB_BLOCK_COUNT (fs))
	return 1;

    return 0;
}


// in reiserfs version 0 (undistributed bitmap)
// FIXME: what if number of bitmaps is 15?
int get_journal_old_start_must (struct reiserfs_super_block * rs)
{
    return 3 + rs_bmap_nr (rs);
}


// in reiserfs version 1 (distributed bitmap) journal starts at 18-th
//
int get_journal_start_must (int blocksize)
{
    return (REISERFS_DISK_OFFSET_IN_BYTES / blocksize) + 2;
}

int get_bmap_num (struct super_block * s)
{
    return ((is_prejournaled_reiserfs (s->s_rs)) ?
	    (((struct reiserfs_super_block_v0 *)s->s_rs)->s_bmap_nr) :
	    SB_BMAP_NR (s));
}

int get_block_count (struct super_block * s)
{
    return ((is_prejournaled_reiserfs (s->s_rs)) ?
	    (((struct reiserfs_super_block_v0 *)s->s_rs)->s_block_count) :
	    SB_BLOCK_COUNT (s));
}

int get_root_block (struct super_block * s)
{
    return  ((is_prejournaled_reiserfs (s->s_rs)) ?
	     (((struct reiserfs_super_block_v0 *)s->s_rs)->s_root_block) :
	     SB_ROOT_BLOCK (s));
}



int journal_size (struct super_block * s)
{
    return JOURNAL_BLOCK_COUNT;
}



int check_item_f (reiserfs_filsys_t fs, struct item_head * ih, char * item);


/* make sure that key format written in item_head matches to key format
   defined looking at the key */
static int is_key_correct (struct item_head * ih)
{
    if (is_stat_data_ih (ih)) {
	/* stat data key looks identical in both formats */
	if (ih_item_len (ih) == SD_SIZE && ih_key_format (ih) == KEY_FORMAT_2) {
	    /*printf ("new stat data\n");*/
	    return 1;
	}
	if (ih_item_len (ih) == SD_V1_SIZE && ih_key_format (ih) == KEY_FORMAT_1) {
	    /*printf ("old stat data\n");*/
	    return 1;
	}
	return 0;
    }
    if (ih_key_format (ih) == key_format (&ih->ih_key))
	return 1;
    return 0;
}


/* check stat data item length, ih_free_space, mode */
static int is_bad_sd (reiserfs_filsys_t fs, struct item_head * ih, char * item)
{
    mode_t mode;

    if (ih_entry_count (ih) != 0xffff)
	return 1;

    if (ih_key_format (ih) == KEY_FORMAT_1) {
	struct stat_data_v1 * sd = (struct stat_data_v1 *)item;

	if (ih_item_len (ih) != SD_V1_SIZE)
	    /* old stat data must be 32 bytes long */
	    return 1;
	mode = le16_to_cpu (sd->sd_mode);
    } else if (ih_key_format (ih) == KEY_FORMAT_2) {
	struct stat_data * sd = (struct stat_data *)item;

	if (ih_item_len (ih) != SD_SIZE)
	    /* new stat data must be 44 bytes long */
	    return 1;
	mode = le16_to_cpu (sd->sd_mode);
    } else
	return 1;
    
    if (!S_ISDIR (mode) && !S_ISREG (mode) && !S_ISCHR (mode) && 
	!S_ISBLK (mode) && !S_ISLNK (mode) && !S_ISFIFO (mode) &&
	!S_ISSOCK (mode))
	return 1;

    return 0;
}


/* symlinks created by 3.6.x have direct items with ih_free_space == 0 */
static int is_bad_direct (reiserfs_filsys_t fs, struct item_head * ih, char * item)
{
    if (ih_entry_count (ih) != 0xffff && ih_entry_count (ih) != 0)
	return 1;
    return 0;
}


/* check item length, ih_free_space for pure 3.5 format, unformatted node
   pointers */
static int is_bad_indirect (reiserfs_filsys_t fs, struct item_head * ih, char * item,
			    check_unfm_func_t check_unfm_func)
{
    int i;
    __u32 * ind = (__u32 *)item;

    if (ih_item_len (ih) % UNFM_P_SIZE)
	return 1;

    for (i = 0; i < I_UNFM_NUM (ih); i ++) {
	if (!ind [i])
	    continue;
	if (check_unfm_func && check_unfm_func (fs, ind [i]))
	    return 1;
    }

    if (fs->s_version == REISERFS_VERSION_1) {
	/* check ih_free_space for 3.5 format only */
	if (ih_free_space (ih) > fs->s_blocksize - 1)
	    return 1;
    }
    
    return 0;
}


static const struct {
    hashf_t func;
    char * name;
} hashes[] = {{0, "not set"},
	      {keyed_hash, "\"tea\""},
	      {yura_hash, "\"rupasov\""},
	      {r5_hash, "\"r5\""}};

#define HASH_AMOUNT (sizeof (hashes) / sizeof (hashes [0]))


int known_hashes (void)
{
    return HASH_AMOUNT;
}


#define good_name(hashfn,name,namelen,deh_offset) \
(GET_HASH_VALUE ((hashfn) (name, namelen)) == GET_HASH_VALUE (deh_offset))


/* this also sets hash function */
int is_properly_hashed (reiserfs_filsys_t fs,
			char * name, int namelen, __u32 offset)
{
    int i;

    if (namelen == 1 && name[0] == '.') {
	if (offset == DOT_OFFSET)
	    return 1;
	return 0;
    }

    if (namelen == 2 && name[0] == '.' && name[1] == '.') {
	if (offset == DOT_DOT_OFFSET)
	    return 1;
	return 0;
    }

    if (hash_func_is_unknown (fs)) {
	/* try to find what hash function the name is sorted with */
	for (i = 1; i < HASH_AMOUNT; i ++) {
	    if (good_name (hashes [i].func, name, namelen, offset)) {
		if (!hash_func_is_unknown (fs)) {
		    /* two or more hash functions give the same value for this
                       name */
		    fprintf (stderr, "Detecting hash code: could not detect hash with name \"%.*s\"\n",
			     namelen, name);
		    reiserfs_hash (fs) = 0;
		    return 1;
		}

		/* set hash function */
		reiserfs_hash(fs) = hashes [i].func;
	    }
	}
    }

    if (good_name (reiserfs_hash(fs), name, namelen, offset))
	return 1;
#if 0
    fprintf (stderr, "is_properly_hashed: namelen %d, name \"%s\", offset %u, hash %u\n",
	    namelen, name_from_entry (name, namelen), GET_HASH_VALUE (offset),
	    GET_HASH_VALUE (reiserfs_hash(fs) (name, namelen)));

    /* we could also check whether more than one hash function match on the
       name */
    for (i = 1; i < sizeof (hashes) / sizeof (hashes [0]); i ++) {
	if (i == g_real_hash)
	    continue;
	if (good_name (hashes[i], name, namelen, deh_offset)) {
	    die ("bad_hash: at least two hashes got screwed up with this name: \"%s\"",
		 bad_name (name, namelen));
	}
    }
#endif
    return 0;
}


int find_hash_in_use (char * name, int namelen, __u32 hash_value_masked, int code_to_try_first)
{
    int i;

    if (code_to_try_first) {
	if (hash_value_masked == GET_HASH_VALUE (hashes [code_to_try_first].func (name, namelen)))
	    return code_to_try_first;
    }
    for (i = 1; i < HASH_AMOUNT; i ++) {
	if (i == code_to_try_first)
	    continue;
	if (hash_value_masked == GET_HASH_VALUE (hashes [i].func (name, namelen)))
	    return i;
    }

    /* not matching hash found */
    return UNSET_HASH;
}


char * code2name (int code)
{
    if (code >= HASH_AMOUNT)
	code = 0;
    return hashes [code].name;
}


int func2code (hashf_t func)
{
    int i;
    
    for (i = 0; i < HASH_AMOUNT; i ++)
	if (func == hashes [i].func)
	    return i;

    reiserfs_panic ("func2code: no hashes matches this function\n");
    return 0;
}


hashf_t code2func (int code)
{
    if (code >= HASH_AMOUNT) {
	reiserfs_warning (stderr, "code2func: wrong hash code %d.\n"
			  "Using default %s hash function\n", code,
			  code2name (DEFAULT_HASH));
	code = DEFAULT_HASH;
    }
    return hashes [code].func;
}


int dir_entry_bad_location (struct reiserfs_de_head * deh, struct item_head * ih, int first)
{
    if (deh_location (deh) < DEH_SIZE * ih_entry_count (ih))
	return 1;
    
    if (deh_location (deh) >= ih_item_len (ih))
	return 1;

    if (!first && deh_location (deh) >= deh_location (deh - 1))
	return 1;

    return 0;
}


/* the only corruption which is not considered fatal - is hash mismatching. If
   bad_dir is set - directory item having such names is considered bad */
static int is_bad_directory (reiserfs_filsys_t fs, struct item_head * ih, char * item,
			     int bad_dir)
{
    int i;
    int namelen;
    struct reiserfs_de_head * deh = (struct reiserfs_de_head *)item;
    __u32 prev_offset = 0;
    __u16 prev_location = ih_item_len (ih);
    
    for (i = 0; i < ih_entry_count (ih); i ++, deh ++) {
	if (deh_location (deh) >= prev_location)
	    return 1;
	prev_location = deh_location (deh);
	    
	namelen = name_length (ih, deh, i);
	if (namelen > REISERFS_MAX_NAME_LEN (fs->s_blocksize)) {
	    return 1;
	}
	if (deh_offset (deh) <= prev_offset)
	    return 1;
	prev_offset = deh_offset (deh);
	
	/* check hash value */
	if (!is_properly_hashed (fs, item + prev_location, namelen, prev_offset)) {
	    if (bad_dir)
		/* make is_bad_leaf to not insert whole leaf. Node will be
		   marked not-insertable and put into tree item by item in
		   pass 2 */
		return 1;
	}
    }

    return 0;
}

/* used by debugreisrefs -p only yet */
#if 1
int is_it_bad_item (reiserfs_filsys_t fs, struct item_head * ih, char * item,
		    check_unfm_func_t check_unfm, int bad_dir)
{
    int retval;

    if (!is_key_correct (ih)) {
	reiserfs_warning (stderr, "is_key_correct %H\n", ih);
	return 1;
    }

    if (is_stat_data_ih (ih)) {
	retval = is_bad_sd (fs, ih, item);
	/*
	if (retval)
	reiserfs_warning (stderr, "is_bad_sd %H\n", ih);*/
	return retval;
    }
    if (is_direntry_ih (ih)) {
	retval =  is_bad_directory (fs, ih, item, bad_dir);
	/*
	if (retval)
	reiserfs_warning (stderr, "is_bad_directory %H\n", ih);*/
	return retval;
    }
    if (is_indirect_ih (ih)) {
	retval = is_bad_indirect (fs, ih, item, check_unfm);
	/*
	if (retval)
	reiserfs_warning (stderr, "is_bad_indirect %H\n", ih);*/
	return retval;
    }
    if (is_direct_ih (ih)) {
	retval =  is_bad_direct (fs, ih, item);
	/*
	  if (retval)
	  reiserfs_warning (stderr, "is_bad_direct %H\n", ih);*/
	return retval;
    }
    return 1;
}
#endif



/* prepare new or old stat data for the new directory */
void make_dir_stat_data (int blocksize, int key_format, 
			 __u32 dirid, __u32 objectid, 
			 struct item_head * ih, void * sd)
{
    memset (ih, 0, IH_SIZE);
    ih->ih_key.k_dir_id = cpu_to_le32 (dirid);
    ih->ih_key.k_objectid = cpu_to_le32 (objectid);
    set_offset (key_format, &ih->ih_key, SD_OFFSET);
    set_type (key_format, &ih->ih_key, TYPE_STAT_DATA);

    set_key_format (ih, key_format);
    set_free_space (ih, MAX_US_INT);

    if (key_format == KEY_FORMAT_2)
    {
        struct stat_data *sd_v2 = (struct stat_data *)sd;

	set_ih_item_len (ih, SD_SIZE);
        sd_v2->sd_mode = cpu_to_le16 (S_IFDIR + 0755);
        sd_v2->sd_nlink = cpu_to_le32 (2);
        sd_v2->sd_uid = 0;
        sd_v2->sd_gid = 0;
        sd_v2->sd_size = cpu_to_le64 (EMPTY_DIR_SIZE);
        sd_v2->sd_atime = sd_v2->sd_ctime = sd_v2->sd_mtime = cpu_to_le32 (time (NULL));
        sd_v2->u.sd_rdev = 0;
        sd_v2->sd_blocks = cpu_to_le32 (dir_size2st_blocks (blocksize, EMPTY_DIR_SIZE));
    }else{
        struct stat_data_v1 *sd_v1 = (struct stat_data_v1 *)sd;

	set_ih_item_len (ih, SD_V1_SIZE);
        sd_v1->sd_mode = cpu_to_le16 (S_IFDIR + 0755);
        sd_v1->sd_nlink = cpu_to_le16 (2);
        sd_v1->sd_uid = 0;
        sd_v1->sd_gid = 0;
        sd_v1->sd_size = cpu_to_le32 (EMPTY_DIR_SIZE_V1);
        sd_v1->sd_atime = sd_v1->sd_ctime = sd_v1->sd_mtime = cpu_to_le32 (time (NULL));
        sd_v1->u.sd_blocks = cpu_to_le32 (dir_size2st_blocks (blocksize, EMPTY_DIR_SIZE_V1));
	sd_v1->sd_first_direct_byte = cpu_to_le32 (NO_BYTES_IN_DIRECT_ITEM);
    }
}


static void _empty_dir_item (int format, char * body, __u32 dirid, __u32 objid,
			     __u32 par_dirid, __u32 par_objid)
{
    struct reiserfs_de_head * deh;

    memset (body, 0, (format == KEY_FORMAT_2 ? EMPTY_DIR_SIZE : EMPTY_DIR_SIZE_V1));
    deh = (struct reiserfs_de_head *)body;
    
    /* direntry header of "." */
    deh[0].deh_offset = cpu_to_le32 (DOT_OFFSET);
    deh[0].deh_dir_id = cpu_to_le32 (dirid);
    deh[0].deh_objectid = cpu_to_le32 (objid);
    deh[0].deh_state = 0;
    set_bit (DEH_Visible, &(deh[0].deh_state));
  
    /* direntry header of ".." */
    deh[1].deh_offset = cpu_to_le32 (DOT_DOT_OFFSET);
    /* key of ".." for the root directory */
    deh[1].deh_dir_id = cpu_to_le32 (par_dirid);
    deh[1].deh_objectid = cpu_to_le32 (par_objid);
    deh[1].deh_state = 0;
    set_bit (DEH_Visible, &(deh[1].deh_state));

    if (format == KEY_FORMAT_2) {
	deh[0].deh_location = cpu_to_le16 (EMPTY_DIR_SIZE - ROUND_UP (strlen (".")));
	deh[1].deh_location = cpu_to_le16 (deh_location (&deh[0]) - ROUND_UP (strlen ("..")));
    } else {
	deh[0].deh_location = cpu_to_le16 (EMPTY_DIR_SIZE_V1 - strlen ("."));
	deh[1].deh_location = cpu_to_le16 (deh_location (&deh[0]) - strlen (".."));
    }

    /* copy ".." and "." */
    memcpy (body + deh_location (&deh[0]), ".", 1);
    memcpy (body + deh_location (&deh[1]), "..", 2);
    
}


void make_empty_dir_item_v1 (char * body, __u32 dirid, __u32 objid,
			     __u32 par_dirid, __u32 par_objid)
{
    _empty_dir_item (KEY_FORMAT_1, body, dirid, objid, par_dirid, par_objid);
}


void make_empty_dir_item (char * body, __u32 dirid, __u32 objid,
			  __u32 par_dirid, __u32 par_objid)
{
    _empty_dir_item (KEY_FORMAT_2, body, dirid, objid, par_dirid, par_objid);
}



/* for every item call common action and an action corresponding to
   item type */
void for_every_item (struct buffer_head * bh, item_head_action_t action,
		     item_action_t * actions)
{
    int i;
    struct item_head * ih;
    item_action_t iaction;

    ih = B_N_PITEM_HEAD (bh, 0);
    for (i = 0; i < node_item_number (bh); i ++, ih ++) {
	if (action)
	    action (ih);

	iaction = actions[get_type (&ih->ih_key)];
	if (iaction)
	    iaction (bh, ih);
    }
}


