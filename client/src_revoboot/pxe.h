typedef __signed__ char __s8;
typedef unsigned char __u8;
typedef __signed__ short __s16;
typedef unsigned short __u16;
typedef __signed__ int __s32;
typedef unsigned int __u32;

unsigned short pxe_call(int func,void *ptr);

void oldpxe(void);
void pxe_emulation(void);

void set_pxe_entry(unsigned short,unsigned short);
void pxe_unload(void);

