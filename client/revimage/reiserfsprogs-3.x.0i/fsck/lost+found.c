/*
 * Copyright 2000-2001 Hans Reiser
 */

#include "fsck.h"


/* fixme: search_by_key is not needed after any add_entry */
static void _look_for_lost (reiserfs_filsys_t fs, int link_lost_dirs)
{
    struct key key, prev_key, * rdkey;
    INITIALIZE_PATH (path);
    int item_pos;
    struct buffer_head * bh;
    struct item_head * ih;
    unsigned long leaves;
    int is_it_dir;
    static int lost_files = 0; /* looking for lost dirs we calculate amount of
				  lost files, so that when we will look for
				  lost files we will be able to stop when
				  there are no lost files anymore */
    int retval;

    key = root_dir_key;

    if (!link_lost_dirs && !lost_files) {
	/* we have to look for lost files but we know already that there are
           no any */
	return;
    }
	
    fsck_progress ("Looking for lost %s:\n", link_lost_dirs ? "directories" : "files");
    leaves = 0;

    while (1) {
	retval = usearch_by_key (fs, &key, &path);
	/* fixme: we assume path ends up with a leaf */
	bh = get_bh (&path);
	item_pos = get_item_pos (&path);
	if (retval != ITEM_FOUND) {
	    if (item_pos == node_item_number (bh)) {
		rdkey = uget_rkey (&path);
		if (!rdkey) {
		    pathrelse (&path);
		    break;
		}
		key = *rdkey;
		pathrelse (&path);
		continue;
	    }
	    /* we are on the item in the buffer */
	}

	/* print ~ how many leaves were scanned and how fast it was */
	if (!fsck_quiet (fs))
	    print_how_fast (0, leaves++, 50);

	for (ih = get_ih (&path); item_pos < node_item_number (bh); item_pos ++, ih ++) {
	    if (is_item_reachable (ih))
		continue;

	    /* found item which can not be reached */
	    if (!is_direntry_ih (ih) && !is_stat_data_ih (ih)) {
		continue;
	    }

	    if (is_direntry_ih (ih)) {
		/* if this directory has no stat data - try to recover it */
		struct key sd;
		struct path tmp;

		sd = ih->ih_key;
		set_type_and_offset (KEY_FORMAT_1, &sd, SD_OFFSET, TYPE_STAT_DATA);
		if (usearch_by_key (fs, &sd, &tmp) == ITEM_FOUND) {
		    /* should not happen - because if there were a stat data -
                       we would have done with the whole directory */
		    pathrelse (&tmp);
		    continue;
		}
		stats(fs)->dir_recovered ++;
		create_dir_sd (fs, &tmp, &sd);
		key = sd;
		pathrelse (&path);
		goto cont;
	    }

	    /* stat data marked "not having name" found */
	    is_it_dir = (not_a_directory (B_I_PITEM (bh,ih)) ? 0 : 1);


	    if (link_lost_dirs && !is_it_dir) {
		/* we are looking for directories and it is not a dir */
		lost_files ++;
		stats(fs)->lost_found_files ++;
		continue;
	    }
	  
	    {
		struct key obj_key = {0, 0, {{0, 0},}};
		char lost_name[80];

		sprintf (lost_name, "%u_%u", le32_to_cpu (ih->ih_key.k_dir_id),
			 le32_to_cpu (ih->ih_key.k_objectid));
		/* entry in lost+found directory will point to this key */
		obj_key.k_dir_id = ih->ih_key.k_dir_id;
		obj_key.k_objectid = ih->ih_key.k_objectid;

		/* need this to continue */
		key = obj_key;
		key.k_objectid ++;
		/*get_next_key (&path, i, &key);*/

		pathrelse (&path);
		
		/* 0 does not mean anyting - item w/ "." and ".." already
		   exists and reached, so only name will be added */
		reiserfs_add_entry (fs, &lost_found_dir_key, lost_name, &obj_key, 0/*fsck_need*/,
				    1/*lost&found*/);

		if (is_it_dir) {
		    /* fixme: we hope that if we will try to pull all the
		       directory right now - then there will be less
		       lost_found things */
		    stats(fs)->lost_found_dirs ++;
		    fsck_progress ("\tChecking lost dir \"%s\":", lost_name);
		    check_semantic_tree (&lost_found_dir_key, &root_dir_key, 0, 1/* lost+found*/);
		    fsck_progress ("ok\n");
		} else {
		    /* check file */
		    stats(fs)->lost_found_files ++;
		    check_semantic_tree (&lost_found_dir_key, &root_dir_key, 0, 1/* lost+found*/);
		}

		if (!link_lost_dirs) {
		    lost_files --;
		}
		goto cont;
	    }
	} /* for */

	prev_key = key;
	get_next_key (&path, item_pos - 1, &key);
	if (comp_keys (&prev_key, &key) != -1)
	    reiserfs_panic ("pass_3a: key must grow 2: prev=%k next=%k",
			    &prev_key, &key);
	pathrelse (&path);

    cont:
	if (!link_lost_dirs && !lost_files) {
	    fsck_progress ("CONT: breaking a loop\n");
	    break;
	}
    }

    pathrelse (&path);

#if 0
    /* check names added we just have added to/lost+found. Those names are
       marked DEH_Lost_found flag */
    fsck_progress ("Checking lost+found directory.."); fflush (stdout);
    check_semantic_tree (&lost_found_dir_key, &root_dir_key, 0, 1/* lost+found*/);
    fsck_progress ("ok\n");
#endif

    if (!link_lost_dirs && lost_files)
	fsck_log ("look_for_lost: %d files seem to left not linked to lost+found\n",
		  lost_files);

}


void pass_3a_look_for_lost (reiserfs_filsys_t fs)
{
    /* look for lost dirs first */
    _look_for_lost (fs, 1);

    /* link files which are still lost */
    _look_for_lost (fs, 0);

    stage_report (0x3a, fs);
}

