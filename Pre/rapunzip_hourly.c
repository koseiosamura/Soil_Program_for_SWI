#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

void printbc(unsigned char v) {
  unsigned char mask = (char)1 << (sizeof(v) * CHAR_BIT - 1);
  do putchar(mask & v ? '1' : '0');
  while (mask >>= 1);
}

void printb(unsigned int v) {
  unsigned int mask = (int)1 << (sizeof(v) * CHAR_BIT - 1);
  do putchar(mask & v ? '1' : '0');
  while (mask >>= 1);
}

char *read_str(FILE *fp, int len) {
  char *str = malloc(sizeof(char) * len);
  if (fread(str, sizeof(char), len, fp) < len) {
    printf("Error while reading.\n");
    exit(EXIT_FAILURE);
  }
  return str;
}

int read_char(FILE *fp) {
  char c;
  if (fread(&c, sizeof(c), 1, fp) < 1) {
    printf("Error while reading.\n");
    exit(EXIT_FAILURE);
  }
  return c;
}

int read_uchar(FILE *fp) {
  unsigned char c;
  if (fread(&c, sizeof(c), 1, fp) < 1) {
    printf("Error while reading.\n");
    exit(EXIT_FAILURE);
  }
  return c;
}

short read_short(FILE *fp) {
  short n;
  if (fread(&n, sizeof(n), 1, fp) < 1) {
    printf("Error while reading.\n");
    exit(EXIT_FAILURE);
  }
  return n;
}

int read_int(FILE *fp) {
  int n;
  if (fread(&n, sizeof(n), 1, fp) < 1) {
    printf("Error while reading.\n");
    exit(EXIT_FAILURE);
  }
  return n;
}

short *levels;

struct {
  unsigned char level;
  unsigned char rep;
} tableLevRep[128];

int unpack(unsigned char *data, int size, short *out) {
  int ii, ip = 0, op = 0;
  unsigned char d;
  while (ip < size) {
    d = data[ip++];
    if ((d & 0x80) == 0) {
      for (ii = tableLevRep[d].rep + 2; ii > 0; ii--)
	out[op++] = levels[tableLevRep[d].level];
    } else if ((d & 0xE0) == 0xC0) {
      for (ii = data[ip++] + 2; ii > 0; ii--)
	out[op++] = levels[d & 0x1F];
    } else if ((d & 0xC0) == 0x80) {
      out[op++] = levels[d & 0x3F];
    } else if (d == 0xFE) {
      out[op++] = levels[data[ip++]];
    } else {
      fprintf(stderr, "Can't unzip file\n");
      exit(1);
    }
  }
  return op;
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    fprintf(stderr, "[Usage] %s input_file\n", argv[0]);
    return EXIT_FAILURE;
  }

  char *file_inp = argv[1];
  FILE *fp = fopen(file_inp, "rb");
  if (fp == NULL) {
    fprintf(stderr, "Can't open file: %s\n", file_inp);
    return EXIT_FAILURE;
  }

  // ヘッダー読み込み
  char *identifier = read_str(fp, 6);
  char *version = read_str(fp, 5);
  char *editor_comment = read_str(fp, 66);
  unsigned char num1 = read_uchar(fp);
  unsigned char num2 = read_uchar(fp);
  unsigned char num3 = read_uchar(fp);
  
  printf("\n");
  printf("\n");
  printf("===================================== \n");
  printf("        Start unzip RAP data \n");
  printf("===================================== \n");
  printf("\n");

  printf("Indentifier    : %s\n", identifier);
  printf("Edition number : %s\n", version);
  printf("<CR>   %d\n", num1);
  printf("<LF>   %d\n", num2);
  printf("<NULL> %d\n", num3);

  int nmax_data = read_int(fp);
  printf("Data number: %d\n", nmax_data);

  // 時刻情報の保存用
  short time_table[nmax_data][5];

  for (int i = 0; i < nmax_data; i++) {
    short YYYY = read_short(fp);
    unsigned char MM = read_uchar(fp);
    unsigned char DD = read_uchar(fp);
    unsigned char hh = read_uchar(fp);
    unsigned char mm = read_uchar(fp);
    short kind = read_short(fp);
    char *spare_index = read_str(fp, 8);
    int position = read_int(fp);
    printf("%2d %04d/%02d/%02d_%02d:%02d\n", i, YYYY, MM, DD, hh, mm);

    time_table[i][0] = YYYY;
    time_table[i][1] = MM;
    time_table[i][2] = DD;
    time_table[i][3] = hh;
    time_table[i][4] = mm;
  }

  char *spare_grid1 = read_str(fp, 2);
  short map_type = read_short(fp);
  int lon = read_int(fp);
  int lat = read_int(fp);
  int intvl_h = read_int(fp);
  int intvl_v = read_int(fp);
  short hmax = read_short(fp);
  short vmax = read_short(fp);
  char *spare_grid2 = read_str(fp, 16);

  printf("Map: %d\n", map_type);
  printf("Lon: %d, Lat: %d\n", lon, lat);
  printf("Lon interval: %d, Lat interval: %d\n", intvl_h, intvl_v);
  printf("Number of Lon: %d, Number of Lat: %d\n", hmax, vmax);

  short compress_mode = read_short(fp);
  short level_max = read_short(fp);
  printf("Unzip method: %d\n", compress_mode);
  printf("Level: %d\n", level_max);

  levels = malloc(sizeof(short) * level_max);
  printf(" Level Precipitation (0.1 mm)\n");
  for (int i = 0; i < level_max; i++) {
    short val = read_short(fp);
    levels[i] = val;
    printf("  %d %d\n", i, val);
  }

  short size_table = read_short(fp);
  printf("Size of the table: %d \n", size_table);
  printf("  No. level itelation-2 \n");
  for (int i = 0; i < size_table; i++) {
    unsigned char level = read_uchar(fp);
    unsigned char repeat = read_uchar(fp);
    tableLevRep[i].level = level;
    tableLevRep[i].rep = repeat;
    printf("%3d %4d %6d\n", i, level, repeat);
  }

  // データ本体の読み取りと1時間ごとの出力
  for (int n = 0; n < nmax_data; n++) {
    printf("Data %2d\n", n);
    int size = read_int(fp);
    printf(" Size after unzip: %d\n", size);

    unsigned char data[size];
    for (int i = 0; i < size; i++) data[i] = read_uchar(fp);

    short out[hmax * vmax];
    if (unpack(data, size, out) != hmax * vmax) {
      fprintf(stderr, "Mismatch number of size\n");
      exit(EXIT_FAILURE);
    }

    // 出力ファイル名
    char out_filename[256];
    snprintf(out_filename, sizeof(out_filename), "output_%04d%02d%02d_%02d%02d.bin",
	     time_table[n][0], time_table[n][1], time_table[n][2],
	     time_table[n][3], time_table[n][4]);

    FILE *wfp = fopen(out_filename, "wb");
    if (!wfp) {
      fprintf(stderr, "Can't open file: %s\n", out_filename);
      exit(EXIT_FAILURE);
    }

    fwrite(out, sizeof(short), hmax * vmax, wfp);
    fclose(wfp);
    printf(" Output name: %s\n", out_filename);

    char *state = read_str(fp, 8);
    int n_amedas = read_int(fp);
    printf(" Number of AMeDAS: %d\n", n_amedas);
  }

  fclose(fp);
  free(levels);
  return 0;
}
