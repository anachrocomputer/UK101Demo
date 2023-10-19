/* pbm2fcb --- convert a PBM bitmap file into FCB data      2010-12-24 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXLINE   (256)

int main(int argc, char *argv[])
{
   int ch;
   int row;
   int col;
   int byt;
   int bit;
   int fcb;
   int mask;
   char buf[MAXLINE];
   char *p;
   FILE *fp;
   
   if (argc != 2) {
      fprintf(stderr, "Usage: %s <filename>\n", argv[0]);
      exit (1);
   }
   
   if ((fp = fopen(argv[1], "r")) == NULL) {
      perror(argv[1]);
      exit (1);
   }
   
   if (fgets(buf, MAXLINE, fp) == NULL) {
      perror("fgets 1");
      exit (1);
   }

   if (fgets(buf, MAXLINE, fp) == NULL) {
      perror("fgets 2");
      exit (1);
   }

   if (fgets(buf, MAXLINE, fp) == NULL) {
      perror("fgets 3");
      exit (1);
   }
   
   strcpy(buf, argv[1]);
   if ((p = strrchr(buf, '.')) != NULL)
      *p = '\0';
   
   for (row = 0; row < 32; row++) {
      if (row == 0)
         printf("%-16.16sfcb ", buf);
      else
         printf("                fcb ");
      for (byt = 0; byt < 6; byt++) {
         fcb = 0;
         mask = 0x80;
         for (bit = 0; bit < 8; bit++) {
            ch = fgetc(fp);
            if (ch == EOF) {
               perror("fgetc");
               exit (1);
            }
            else if (ch == '\n')
               ch = fgetc(fp);
            
            if (ch == '1')
               fcb |= mask;
            
            mask >>= 1;
         }
         
         printf("$%02x", fcb);
         
         if (byt < 5)
            printf(",");
         else
            printf(" ; row %d\n", row);
      }
   }

   fclose(fp);
   
   return (0);
}

