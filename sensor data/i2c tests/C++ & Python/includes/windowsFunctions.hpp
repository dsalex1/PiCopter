#ifndef WINDOWSFUNCTIONS_H_INCLUDED
#define WINDOWSFUNCTIONS_H_INCLUDED

    #include <windows.h>
    void delayMicroseconds(__int64 usec){
        HANDLE timer;
        LARGE_INTEGER ft;

        ft.QuadPart = -(10*usec); // Convert to 100 nanosecond interval, negative value indicates relative time

        timer = CreateWaitableTimer(NULL, TRUE, NULL);
        SetWaitableTimer(timer, &ft, 0, NULL, NULL, 0);
        WaitForSingleObject(timer, INFINITE);
        CloseHandle(timer);
    }
    #include <sys/timeb.h>

    uint64_t micros()
    {
        struct _timeb timebuffer;
        _ftime(&timebuffer);
        return (uint64_t)(((timebuffer.time * 1000) + timebuffer.millitm)*1000);
    }
#endif // WINDOWSFUNCTIONS_H_INCLUDED
