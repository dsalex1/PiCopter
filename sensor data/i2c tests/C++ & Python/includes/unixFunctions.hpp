#ifndef UNIXFUNCTIONS_H_INCLUDED
#define UNIXFUNCTIONS_H_INCLUDED

    #include <unistd.h>
    #include <sys/time.h>
    void delayMicroseconds(uint usec){
        usleep(usec);
    }

    long micros(){
        struct timeval currentTime;
        gettimeofday(&currentTime, NULL);
        return currentTime.tv_sec * (int)1e6 + currentTime.tv_usec;
    }
#endif // UNIXFUNCTIONS_H_INCLUDED
