#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <errno.h>
#include <semaphore.h>
#include <stdbool.h>

#define RESET  "\x1B[0m"
#define RED    "\x1B[31m"
#define GREEN  "\x1B[32m"
#define YELLOW "\x1B[33m"
#define BLUE   "\x1B[34m"
#define WHITE  "\x1B[37m"
#define int long long
#define MAX 1e2

int nwashed;
int N, M, T[1000], W[1000], P[1000];
int timeWasted[1000], washingMachine[1000][1000];
int assigned[1000];
int waste[1000];
int starting_time[1000];
bool waiting[1000];
bool WashingMachineAvailable[1000];
int waitingTotal = 0;
sem_t student_sem;
struct timespec start_time;

pthread_mutex_t washingMachineMutex[1000];

void *startThread(void *arg)
{
    int wm = -1;
    bool assigned = false;
    int studentIdx = *((int *)arg);
    // update_machine(studentIdx);
    int idx = studentIdx;
    sleep(T[idx]);

    printf(WHITE);
    printf("%lld: Student %lld arrives \n", T[idx], idx);
    int ret;
    struct timespec ts;
    if (clock_gettime(CLOCK_REALTIME, &ts) == -1)
    {
        printf("error in getting time");
        exit(0);
    }
    ts.tv_sec += P[idx] + 1;
    while ((ret = sem_timedwait(&student_sem, &ts)) == -1 && errno == EINTR)
    {
    };
    struct timespec temp;
    if (ret == -1)
    {
        if (errno == ETIMEDOUT)
        {
            struct timespec ts;
            if (clock_gettime(CLOCK_REALTIME, &ts) == -1)
            {
                printf("error in getting time");
                exit(0);
            }
            printf(RED);
            printf("%lld: Student %d leaves without washing\n", T[idx] + P[idx], idx);
            waste[idx] += P[idx];
            nwashed++;
        }
        else
        {
            perror("sem_timedwait");
            exit(0);
        }
    }
    else
    {


        for (int A = 1; A <= M; A++)
        {
            if (pthread_mutex_trylock(&washingMachineMutex[A]))
            {
                continue;
            }
            else if (WashingMachineAvailable[A] == true)
            {
                assigned = true;
		 wm = A;
                WashingMachineAvailable[A] = false;
                gettimeofday(&temp, NULL);
                starting_time[idx] = temp.tv_sec;
                waste[idx] = (starting_time[idx] - start_time.tv_sec) - T[idx];
                printf(GREEN);
                printf("%lld: Student %lld starts washing\n", temp.tv_sec - start_time.tv_sec, idx);
                break;
            }
            pthread_mutex_unlock(&washingMachineMutex[A]);
        }
        if (assigned)
        {
            sleep(W[idx]);
            pthread_mutex_unlock(&washingMachineMutex[wm]);
            WashingMachineAvailable[wm] = true;
            struct timespec ts;
            if (clock_gettime(CLOCK_REALTIME, &ts) == -1)
            {
                printf("error in getting time");
                exit(0);
            }
            printf(YELLOW);
            printf("%lld: Student %lld leaves after washing \n", starting_time[idx] + W[idx] - start_time.tv_sec, idx);
            sem_post(&student_sem);
        }
    }

    return NULL;
}

int main()
{
    scanf("%lld", &N);
    scanf("%lld", &M);
    int identity[1000];
    for (int A = 1; A <= N; A++)
    {
        scanf("%lld %lld %lld", &T[A], &W[A], &P[A]);
        assigned[A] = -1;
        identity[A] = A;
    }
    for (int A = 1; A <= M; A++)
    {
        for (int B = 0; B <= M; B++)
        {
            washingMachine[A][B] = -1;
        }
        WashingMachineAvailable[A] = true;
    }
    sem_init(&student_sem, 0, M);
    pthread_t threads[10000];
    gettimeofday(&start_time, NULL);
    for (int A = 1; A <= N; A++)
    {
        usleep(100);
        pthread_create(&threads[A], NULL, startThread, (void *)&identity[A]);
    }
    for (int A = 1; A <= N; A++)
    {
        pthread_join(threads[A], NULL);
    }
    printf("%lld\n", nwashed);
    long long ret = 0;
    for (int i = 1; i <= N; ++i)
    {
        //printf("student %d wasted %d\n", i, waste[i]);
        ret += waste[i];
    }
    printf("%lld\n", ret);
    if (nwashed > N / 4)
        printf("Yes");
    else
        printf("No");
    return 0;
}
//5 2
//6 3 5
//3 4 3
//6 5 2
//2 9 6
//8 5 2

