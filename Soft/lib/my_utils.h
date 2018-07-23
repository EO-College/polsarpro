#ifndef My_utils_flag
#define My_utils_flag

#define my_square(x) ((x)*(x)) 
#define my_max(a,b) ((a)>(b) ? (a):(b))
#define my_min(a,b) ((a)<(b) ? (a):(b))
#define my_wrap_int(a,b)  (((a)>=0) ? ((a)%(int)(b)):((b)+((a)%(int)(b))))
/* a (integer) modulo b and wrapped */

typedef enum {no_cmd_prm,int_cmd_prm,flt_cmd_prm,str_cmd_prm} cmd_prm;

int get_commandline_prm(int argc, char *argv[], char *keyword, cmd_prm type, void *ptr, int required, char *usage);
int get_one_char_only(void);
#endif
