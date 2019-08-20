#include <cpu_cde.h>

int my_rand();
void my_srand(unsigned seed);
static unsigned long rand_next=1;


//------------------
// main()
//------------------

#define runTest(test) (test ? panic(global_id) : global_id++)
#define rep(a, b, c) \
    int a;           \
    for (a = b; a < c; a++)

static int global_id = 0;

int panic(int id)
// this function will save id++ in reg.
{
    id++;
    while (1)
        ;
    return id;
}

int passed()
{
    while (1)
        ;
}

//return 0 means test passed
int loopTest(int loopSize)
{
    int sum = 0;
    int i;
    for (i = 0; i < loopSize; i++)
    {
        sum++;
    }

    if (sum == loopSize)
        return 0;
    else
    {
        return 1;
    }
}

int nestingLoopTest(int outerSize, int innerSize)
//run a 2-layer loop, test if all insts runs correctly
{
    int sum = 0;
    rep(a, 0, outerSize)
    {
        rep(b, 0, innerSize)
        {
            sum++;
        }
    }

    if (sum == (outerSize * innerSize))
        return 0;
    return 1;
}

int arrayTest(int outerSize, int innerSize, int times)
//this test will write data into an array to test dcache
{
    int sum = 0;
    int size = outerSize * innerSize;
    int array[outerSize][innerSize];

    rep(c, 0, times)
    {
        rep(a, 0, outerSize)
        {
            rep(b, 0, innerSize)
            {
                if (c == 0)
                {
                    //pass
                }
                else
                {
                    if(array[a][b]!=(sum-size))
                        return 1;
                }
                array[a][b] = sum++;
            }
        }
    }

    if (sum == (outerSize * innerSize * times))
        return 0;
    return 1;
}

int memory_game()
{
    my_srand(0);

    // loop test
    runTest(loopTest(8));    //0
    runTest(loopTest(16));   //1
    runTest(loopTest(32));   //2
    runTest(loopTest(64));   //3
    runTest(loopTest(128));  //4
    runTest(loopTest(1024)); //5

    // nesting loop test
    runTest(nestingLoopTest(2, 8));  //6
    runTest(nestingLoopTest(8, 2));  //7
    runTest(nestingLoopTest(8, 8));  //8
    runTest(nestingLoopTest(7, 13)); //9
    runTest(nestingLoopTest(5, 42)); //10

    runTest(arrayTest(10, 10, 5)); //11
    runTest(arrayTest(32, 16, 4)); //12

    return 0;
}

int my_rand(void){
    rand_next = rand_next*1103515245 + 12345;
    return ((unsigned)(rand_next/65536)%32768);
}

void my_srand(unsigned seed){
    rand_next = seed;
}
