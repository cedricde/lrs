typedef struct fat16_s
{
	unsigned char BS_DrvNum		__attribute__((packed));
	unsigned char BS_Reserved1	__attribute__((packed));
	unsigned char BS_BootSig	__attribute__((packed));

	unsigned long BS_VolID		__attribute__((packed));
	unsigned char BS_VolLab[11]	__attribute__((packed));
	unsigned char BS_FilSysType[8]	__attribute__((packed));

	unsigned char BootCode[510-62]	__attribute__((packed));

	unsigned short BS_Signature	__attribute__((packed));
} FAT16;

typedef struct fat32_s
{
	unsigned long BPB_FATSz32	__attribute__((packed));
	unsigned short BPB_ExtFlags	__attribute__((packed));
	unsigned short BPB_FSVer	__attribute__((packed));
	unsigned long BPB_RootClus	__attribute__((packed));
	unsigned short BPB_FSInfo	__attribute__((packed));
	unsigned short BPB_BkBootSec	__attribute__((packed));
	unsigned char BPB_Reserved[12]	__attribute__((packed));

	unsigned char BS_DrvNum		__attribute__((packed));
	unsigned char BS_Reserved1	__attribute__((packed));
	unsigned char BS_BootSig	__attribute__((packed));

	unsigned long BS_VolID		__attribute__((packed));
	unsigned char BS_VolLab[11]	__attribute__((packed));
	unsigned char BS_FilSysType[8]	__attribute__((packed));

	unsigned char BootCode[510-90]	__attribute__((packed));

	unsigned short BS_Signature	__attribute__((packed));
} FAT32;

typedef struct fat_s
{
	unsigned char BS_jmpBoot[3]	__attribute__((packed));
	unsigned char BS_OEMName[8]	__attribute__((packed));

	unsigned short BPB_BytsPerSec	__attribute__((packed));
	unsigned char BPB_SecPerClus	__attribute__((packed));
	unsigned short BPB_RsvdSecCnt	__attribute__((packed));
	unsigned char BPB_NumFATs	__attribute__((packed));
	unsigned short BPB_RootEntCnt	__attribute__((packed));
	unsigned short BPB_TotSec16	__attribute__((packed));
	unsigned char BPB_Media		__attribute__((packed));
	unsigned short BPB_FATSz16	__attribute__((packed));
	unsigned short BPB_SecPerTrk	__attribute__((packed));
	unsigned short BPB_NumHeads	__attribute__((packed));
	unsigned long BPB_HiddSec	__attribute__((packed));
	unsigned long BPB_TotSec32	__attribute__((packed));

	union
	{
		FAT16 fat16;
		FAT32 fat32;
	} fat_type ;

} FAT;

