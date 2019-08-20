#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define IO_MAP_BASE     0x1fd00000
#define IO_MAP_SIZE     0x10000
#define LCD_CTRL_ADDR   0xd000
#define TOUCH_SDA_ADDR  0xd004
#define TOUCH_SCL_ADDR  0xd008

int devmemfd;
void *map_base;
volatile uint32_t *lcd_ctrl;
volatile uint32_t *touch_sda;
volatile uint32_t *touch_scl;

typedef uint16_t UINT16;
typedef uint16_t WORD;
typedef uint32_t DWORD;
typedef int32_t LONG;

typedef struct tagBITMAPFILEHEADER 
{  
  UINT16 bfType;    
  DWORD bfSize; 
  UINT16 bfReserved1; 
  UINT16 bfReserved2; 
  DWORD bfOffBits;
} __attribute__((packed)) BITMAPFILEHEADER; 

typedef struct tagBITMAPINFOHEADER{
  DWORD      biSize;
  LONG        biWidth;
  LONG        biHeight;
  WORD       biPlanes;
  WORD       biBitCount;
  DWORD      biCompression;
  DWORD      biSizeImage;
  LONG        biXPelsPerMeter;
  LONG        biYPelsPerMeter;
  DWORD      biClrUsed;
  DWORD      biClrImportant;
} __attribute__((packed)) BITMAPINFOHEADER, *LPBITMAPINFOHEADER, *PBITMAPINFOHEADER;

void initialize_map() {
  devmemfd = open("/dev/mem", O_RDWR|O_SYNC);
  if (devmemfd == -1) {  
    perror("init_map open failed");
    exit(1);
  }
  
  map_base = mmap(NULL, IO_MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, devmemfd, IO_MAP_BASE);
  
  if (map_base == MAP_FAILED) {
    perror("init_map mmap failed");
    close(devmemfd);
    exit(1);
  }
  
  lcd_ctrl  = (void *)((uint8_t *)map_base + LCD_CTRL_ADDR);
  touch_sda = (void *)((uint8_t *)map_base + TOUCH_SDA_ADDR);
  touch_scl = (void *)((uint8_t *)map_base + TOUCH_SCL_ADDR);
  printf("map_base: %p\n", map_base);
  printf("lcd_ctrl: %p\n", lcd_ctrl);
  printf("touch_sda: %p\n", lcd_ctrl);
  printf("touch_scl: %p\n", lcd_ctrl);
}

void finalize_map() {
  munmap(map_base, IO_MAP_SIZE);
	close(devmemfd);
}

#define lcd_inst(inst) (*lcd_ctrl = (1 << 31) | (1 << 16) | (inst))
#define lcd_data(data) (*lcd_ctrl = (1 << 31) | (2 << 16) | (data))

void lcd_init(uint16_t width, uint16_t height) {
  uint16_t xs, xe, ys, ye;
  xs = (800 - width) / 2;
  xe = (800 + width) / 2 - 1;
  ys = (480 - height) / 2;
  ye = (480 + height) / 2 - 1;
  lcd_inst(0x3600);
  lcd_data(0x0020);
  lcd_inst(0x2a00);
  lcd_data(xs>>8);
  lcd_inst(0x2a01);
  lcd_data(xs&0xff);
  lcd_inst(0x2a02);
  lcd_data(xe>>8);
  lcd_inst(0x2a03);
  lcd_data(xe&0xff);
  lcd_inst(0x2b00);
  lcd_data(ys>>8);
  lcd_inst(0x2b01);
  lcd_data(ys&0xff);
  lcd_inst(0x2b02);
  lcd_data(ye>>8);
  lcd_inst(0x2b03);
  lcd_data(ye&0xff);
}

void lcd_write(uint16_t *data, size_t n) {
  size_t i;
  lcd_inst(0x2c00);
  for (i=0; i<n; i++)
    lcd_data(data[i]);
}

void lcd_fill(uint16_t color, size_t n) {
  size_t i;
  lcd_inst(0x2c00);
  for (i=0; i<n; i++)
    lcd_data(color);
}

void *load_bmp(char *fname, uint16_t *pwidth, uint16_t *pheight, uint16_t *pbc) {
  FILE *f;
  BITMAPFILEHEADER bmpfilehdr;
  BITMAPINFOHEADER bmpinfohdr;
  void *data;
  
  f = fopen(fname, "rb");
  if (!f) {
    perror("open file failed");
    return NULL;
  }
  
  fread(&bmpfilehdr, 1, sizeof(BITMAPFILEHEADER), f);
  if (bmpfilehdr.bfType != 0x4d42) {
    fprintf(stderr, "unrecognized file format 0x%x\n", bmpfilehdr.bfType);
    return NULL;
  }
  
  fread(&bmpinfohdr, 1, sizeof(BITMAPINFOHEADER), f);
  if (bmpinfohdr.biBitCount != 24 && bmpinfohdr.biBitCount != 32) {
    fprintf(stderr, "unsupported number of bits per pixel %d\n", bmpinfohdr.biBitCount);
    return NULL;
  }
  if (bmpinfohdr.biWidth > 800 || bmpinfohdr.biHeight > 480) {
    fprintf(stderr, "image dimension is too large\n", bmpinfohdr.biBitCount);
    return NULL;
  }
  
  *pwidth = (uint16_t)bmpinfohdr.biWidth;
  *pheight = (uint16_t)bmpinfohdr.biHeight;
  *pbc = bmpinfohdr.biBitCount;
  data = malloc(bmpfilehdr.bfSize);
  if (!data) {
    perror("malloc failed");
    return NULL;
  }
  
  fseek(f, bmpfilehdr.bfOffBits, SEEK_SET);
  fread(data, 1, bmpfilehdr.bfSize, f);
  fread(data, 1, bmpfilehdr.bfSize, f);
  fclose(f);
  
  return data;
}

int main(int argc, char **argv) {
  unsigned char *data, *p;
  uint16_t width, height, bc;
  int i, total;
  
  if (argc != 2)
    return -1;
  
  initialize_map();
  
  if (!(data = load_bmp(argv[1], &width, &height, &bc)))
    return -1;
  
  lcd_init(800, 480);
  lcd_fill(0, 800*480);
  
  lcd_init(width, height);
  lcd_inst(0x2c00);
  
  total = width * height;
  p = data;
  for (i=0; i<total; i++) {
    uint16_t val;
    val = 0;
    val |= (*p++ >> 3);
    val |= (*p++ >> 2) << 5;
    val |= (*p++ >> 3) << 11;
    if (bc == 32) p++;
    lcd_data(val);
  }
  
  free(data);
  
  finalize_map();
}