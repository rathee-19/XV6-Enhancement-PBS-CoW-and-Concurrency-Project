#include<stdio.h>
#include<pthread.h>
#include<semaphore.h>
#include<time.h>
#include<limits.h>
#include<stdlib.h>
#include<string.h>
#include<unistd.h>

// Variables for questions
int T;
int K;
int N;
int F;

typedef struct Machine
{
    int mac_num;
    int start_time;
    int stop_time;
    int run_time;
}machine;

typedef struct icecream
{
    char name[1024];
    int prep_time;
}flavours;

typedef struct Toppings
{
    char name[1024];
    int quantity; // (-1) means unlimited quantity
}toppings;

typedef struct ice_order
{
    char ice_cream_name[1024];
    int num_top;
    char toppings_ord[10][1024];
}ordered;

typedef struct Customer
{
    int cust_num;
    int arr_time;
    int num_ice;
    ordered* order;
    int prep_t_ice;
}customer;

// global pointers for accesing data;
customer* cust_list;
machine* mac_pointer;
flavours* flav_pointer;
toppings* top_pointer;

int* time_check;

// concurrency
sem_t * machines; // for blocking machine usage
sem_t capacity; // for holding capacity of parlour
sem_t top_lock; // lock for changing value of toopings


// clock variables for synchronization
time_t start_time; // when the cafe starts
time_t rel_time; // for checking seconds passed

// helper functions to organize data
int comparator_1(const void *a, const void *b)
{
    machine*a_1 = (machine*)a;
    machine*b_1 = (machine*)b;

    return (a_1->start_time-b_1->start_time);
}

// making a global clock
void* global_clock(void* arg)
{
    while(1)
    {
        rel_time = time(NULL) - start_time;
    }
    return NULL;
}

// managing machine state
void* machine_status(void* arg)
{
    machine* arr = (machine*)arg;
    // printf("%d\n",mac_pointer[0].run_time);
    printf("\033[1;38;5;202mMachine %d has started working at %d second(s)\n", arr->mac_num,arr->start_time);
    printf("\033[0m");
    while(rel_time < arr->stop_time);
        // printf("%d ",rel_time );
    printf("\033[1;38;5;202mMachine %d has stopped working at %d second(s)\n", arr->mac_num,arr->stop_time);
    printf("\033[0m");
    return NULL;
}

void* make_order (void* arg)
{
    int* ar = (int*)arg;
    while(rel_time < ar[0]);
    // sleep(0.8);
    usleep(10000);
    sem_wait(&machines[ar[1]-1]);
    // sleep()
    printf("\033[1;36mMachine %d starts preparing ice cream %d of customer %d at %d second(s)\n", ar[1],ar[2],ar[3],rel_time);
    printf("\033[0m");
    // while((rel_time - ar[0]) < ar[4]);
    sleep(ar[4]);
    printf("\033[1;34mMachine %d completes preparing ice cream %d of customer %d at %d second(s)\n", ar[1],ar[2],ar[3],rel_time);
    printf("\033[0m");
    sem_post(&machines[ar[1]-1]);
    return NULL;
}

void* machine_intiation (void* arg)
{
    pthread_t mac[N];
    int mac_count=0;
    while(mac_count<N)
    {
        if(rel_time >= mac_pointer[mac_count].start_time)
        {
            pthread_create(&mac[mac_count],NULL,&machine_status,(void*)&mac_pointer[mac_count]);
            // sleep(0.5);
            mac_count++;
        }
    }
    
    // wait for machine threads to end
    for(int i=0;i<N;i++)
        pthread_join(mac[i],NULL);

    return NULL;
}

// managing customers
void* update_status(void* arg)
{
    customer* temp = (customer*)arg;
    sem_wait(&capacity); // locking shared variable K
    if( K > 0) // parlour has vacancy for more customers
    {
        K--;
        sem_post(&capacity);

        printf("\033[1;37mCustomer %d enters at %d second(s)\n", temp->cust_num,temp->arr_time);
        printf("\033[0m");
        printf("\033[1;33mCustomer %d orders %d ice cream(s)\n", temp->cust_num,temp->num_ice);
        printf("\033[0m");

        sem_wait(&capacity);
        int check_ing=1;
        int ing[T];
        for(int i=0;i<T;i++)
            ing[i]=0;
        for(int i=0;i<temp->num_ice;i++)
        {
            printf("\033[1;33mIce cream %d: %s ", (i+1),temp->order[i].ice_cream_name);
            printf("\033[0m");
            for(int j=0;j<temp->order[i].num_top;j++)
            {
                printf("\033[1;33m%s ", temp->order[i].toppings_ord[j]);
                printf("\033[0m");
                for(int g=0;g<T;g++)
                {
                    if(strcmp(top_pointer[g].name,temp->order[i].toppings_ord[j]) == 0)
                        ing[g]++;
                }                
            }
            printf("\n");
        }
        // sem_wait(&top_lock);
        for(int i=0;i<T;i++)
        {
            if(ing[i] <= top_pointer[i].quantity || top_pointer[i].quantity == (-1))
                check_ing=1;
            else
            {
                check_ing=0;
                break;
            }
        }
        // sem_post(&top_lock);
        sem_post(&capacity);
        pthread_t execute_order[temp->num_ice];
        int final_arr[temp->num_ice][5];
        if(check_ing == 0)
        {
            sem_wait(&capacity);
            K++;
            sem_post(&capacity);
            printf("\033[1;37mCustomer %d left at %d second(s) with an unfulfilled order\n", temp->cust_num,rel_time);
            printf("\033[0m");
        }
        else
        {
            int check_completion = 1;
            int threads_st=0;
            for(int i=0;i<temp->num_ice;i++)
            {
                sem_wait(&capacity);
                int prep_time_fin;
                for(int j=0;j<F;j++)
                {
                    if(strcmp(flav_pointer[j].name,temp->order[i].ice_cream_name) == 0)
                    {
                        prep_time_fin=flav_pointer[j].prep_time;
                        break;
                    }
                }
                int chosen_mac_num = 0;
                int start_time_exec = 1000000000;
                int close_time = INT_MIN; // used to display the machine unavailabilty at last
                for(int j=0;j<N;j++)
                {
                    if(close_time < mac_pointer[j].stop_time)
                        close_time = mac_pointer[j].stop_time;
                }
                for(int j=0;j<N;j++) // selecting machine for order
                {
                    if(temp->arr_time <= time_check[j])
                    {
                        if((time_check[j] + prep_time_fin) <= mac_pointer[j].stop_time && time_check[j] < start_time_exec)
                        {
                            start_time_exec = time_check[j];
                            chosen_mac_num = (j+1);
                        }
                    }
                    else if (temp->arr_time > time_check[j] && ((temp->arr_time + prep_time_fin) <= mac_pointer[j].stop_time) )
                    {
                        start_time_exec = temp->arr_time;
                        chosen_mac_num = (j+1);
                    }
                }
                if(i==0)
                {
                    start_time_exec += 1;
                }
                if(chosen_mac_num == 0) // no machine found
                {
                    sem_post(&capacity);
                    while(rel_time < close_time);
                    printf("\033[1;31mCustomer %d was not serviced due to unavailability of machines\n", temp->cust_num);
                    printf("\033[0m");
                    sem_wait(&capacity);
                    K++;
                    sem_post(&capacity);
                    check_completion = 0;
                    break;
                }
                else
                {
                    time_check[chosen_mac_num-1] = start_time_exec + prep_time_fin + 1;
                    sem_post(&capacity);
                }
                int flag_top = 0;
                sem_wait(&capacity);
                for(int j=0;j < temp->order[i].num_top;j++)
                {
                    for(int y =0 ;y<T;y++)
                    {
                        if(strcmp(top_pointer[y].name,temp->order[i].toppings_ord[j]) == 0 && top_pointer[y].quantity != (-1))
                        {
                            if(top_pointer[y].quantity == 0)
                            {
                                flag_top = 1;
                                break;
                            }
                            top_pointer[y].quantity -= 1;
                            break;                    
                        }
                    }
                    if(flag_top == 1)
                        break;
                }
                sem_post(&capacity);
                if(flag_top == 1)
                    break;
                sem_wait(&capacity);
                final_arr[i][0]=start_time_exec; // store execution time
                final_arr[i][1]=chosen_mac_num; // store mac number
                final_arr[i][2]=(i+1); // order id
                final_arr[i][3]=temp->cust_num; // cust_num
                final_arr[i][4]=prep_time_fin;
                sem_post(&capacity);
                pthread_create(&execute_order[i],NULL,&make_order,(void*) &final_arr[i]);
                threads_st++;
            }
            for(int j=0;j<threads_st;j++)
            {
                pthread_join(execute_order[j],NULL);
            }
            if(check_completion)
            {
                printf("\033[1;32mCustomer %d has collected their order(s) and left at %d second(s)\n", temp->cust_num,rel_time);
                printf("\033[0m");  
                sem_wait(&capacity);
                K++;
                sem_post(&capacity);   
            }
        }
    }
    else
        sem_post(&capacity); // customer cannot be entertained so we take control back

    return NULL;
}


int main()
{
    N = 0;  // ice-cream Machines
    F = 0;  // ice-cream flavours 
    T = 0;  // Toppings
    K = 0;  // Capacity of customers

    scanf("%d %d %d %d",&N, &K, &F, &T);

    time_check = (int*)malloc(sizeof(int)*N); // for checking time dynamically to schedule orders

    // input for machines and their working times
    machine mac_work[N];
    mac_pointer = mac_work;

    for(int i = 0 ; i < N ; i++)
    {
        mac_work[i].mac_num=(i+1);
        scanf("%d %d", &mac_work[i].start_time,&mac_work[i].stop_time);
        mac_work[i].run_time=(mac_work[i].stop_time - mac_work[i].start_time);
        time_check[i]=mac_work[i].start_time;
    }
    
    qsort(mac_work,N,sizeof(machine),comparator_1);
    
    // input for flavours of ice-creams
    flavours var_ice[F];
    flav_pointer=var_ice;

    for(int i = 0 ; i < F ; i++)
    {
        for(int j=0;j<1024;j++)
            var_ice[i].name[j]='\0';
        scanf("%s %d",&var_ice[i].name,&var_ice[i].prep_time);
    }

    //input for toppings and their quantities
    toppings var_top[T];
    top_pointer = var_top;
    for(int i = 0 ; i < T ; i++)
    {
        for(int j=0;j<1024;j++)
            var_top[i].name[j]='\0';
        scanf("%s %d",&var_top[i].name,&var_top[i].quantity);        
    }

    char str[4096];
    memset(str, 0, sizeof(str));
    int num_customs=0;
    int flag=0;

    cust_list = (customer*)malloc(sizeof(customer)*100);

    // input for customers
    while(fgets(str,4096,stdin))
    {
        if(strcmp(str,"\n") == 0) // condition for signaling end of customers
        {
            flag++;
            if(flag == 2)
                break;
            continue;
        }

        char* tokken = strtok(str," \n");
        cust_list[num_customs].cust_num=atoi(tokken);
        tokken = strtok(NULL," \n");
        cust_list[num_customs].arr_time=atoi(tokken);
        tokken = strtok(NULL," \n");
        cust_list[num_customs].num_ice=atoi(tokken);
        tokken = strtok(NULL," \n");

        cust_list[num_customs].order = (ordered*)malloc(sizeof(ordered)*cust_list[num_customs].num_ice);
        for(int i=0;i<cust_list[num_customs].num_ice;i++)
        {
            cust_list[num_customs].order[i].num_top=0;
            memset(str,0,sizeof(str));
            fgets(str,4096,stdin);
            tokken = strtok(str," \n");
            strcpy(cust_list[num_customs].order[i].ice_cream_name,tokken);
            tokken = strtok(NULL, " \n");
            while(tokken != NULL)
            {
                for(int y=0;y<strlen(tokken);y++)
                    cust_list[num_customs].order[i].toppings_ord[cust_list[num_customs].order[i].num_top][y]=tokken[y];
                cust_list[num_customs].order[i].num_top++;
                tokken = strtok(NULL," \n");
            }
        }
        num_customs++;
    }

    // initalising locks
    sem_init(&capacity,0,1);
    sem_init(&top_lock,0,1);
    sem_t machines_init[N];
    machines = machines_init;
    for(int i=0;i<N;i++)
        sem_init(&machines[i],0,1);

    start_time = time(NULL);

    // function keep running updating time
    pthread_t sync;
    int check_thread = pthread_create(&sync,NULL,&global_clock,NULL);    //https://www.geeksforgeeks.org/thread-functions-in-c-c/
    if(check_thread!=0)
    {
        printf("Error in synchronization\n");
        return 0;
    }
    
    // for machines
    pthread_t mac_main;
    pthread_create(&mac_main,NULL,&machine_intiation,NULL);

    // for customers
    pthread_t custom[num_customs];
    int count_cust=0;
    int flag_check = 0;
    while(count_cust < num_customs)
    {   flag_check = 0;
        if(rel_time >= cust_list[count_cust].arr_time)
        {
            // sem_wait(&top_lock);
            for(int y=0;y<T;y++)
            {
                if(top_pointer[y].quantity != 0)
                {
                    flag_check = 0;
                    break;
                }
                else
                {
                    flag_check = 1;
                }

            }
            // sem_post(&top_lock);
            if(flag_check == 1)
            {
                break;
            }
            pthread_create(&custom[count_cust],NULL,&update_status,(void*) &cust_list[count_cust]);
            if( count_cust != num_customs -1)
            {
                sleep(cust_list[count_cust+1].arr_time-cust_list[count_cust].arr_time);
            }
            else
            {
                usleep(50000); // synchronization
            }
            count_cust++;            
        }
    }

    for(int i=0;i<num_customs;i++)
        pthread_join(custom[i],NULL);

    pthread_join(mac_main,NULL);

    printf("Parlour Closed!\n");
    return 0;

}
