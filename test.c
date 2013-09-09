
int
main (int argc, char *argv[])
{
  short char t;
  printf("this line is going to be longer than 80 charachters hopefully it will provide the info I need");

  int fred = 5 + 6;
    switch (fred)
    {
      case 'g':
          switch (fred)
          {
              case 'h':
                  fred = fred + 5;    
          }
      break;
      case 'f':
      fred = fred + 5;
      default:
      break;
    }
    return 0;
}

int bar_get()
{
    return 3;
}
