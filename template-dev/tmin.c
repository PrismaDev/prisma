#include <stdio.h>

int main(int argc, char* argv[]) {
	if (argc!=3) return 1;
	
	FILE* in=fopen(argv[1],"r");
	FILE* out=fopen(argv[2],"w");

	if (!in || !out) {
		printf("error");
		return 2;
	}

	int tag=0;
	char c,prevC;

	while (fscanf(in,"%c",&c)!=EOF) {
		switch(c) {
			case '\n':
			case '\t':
				break;
			case ' ':
			case '<': tag=1;
			case '>': tag=0;
			default:
				fprintf(out,"%c",c);						
		}
		prevC=c;
	}

	fclose(in);
	fclose(out);
	return 0;
}
