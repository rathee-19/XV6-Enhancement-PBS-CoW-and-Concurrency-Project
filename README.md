# XV6 Enhancement (PBS, CoW) and Concurrency Project

## Overview

This project enhances the XV6 operating system with networking and concurrency capabilities. The key features implemented include Preemptive Priority-Based Scheduling (PBS) and Copy-On-Write (CoW) functionality. These enhancements improve the system's efficiency, responsiveness, and resource utilization.
## Resources
- [Insturctions](https://karthikv1392.github.io/cs3301_osn/mini-projects/mp3)

## Features

### Preemptive Priority-Based Scheduling (PBS)

PBS is a scheduling algorithm that assigns priorities to tasks and preempts lower-priority tasks when higher-priority tasks are ready to run. This ensures that critical tasks receive processor time promptly, making the system more responsive and efficient.

### Benefits

- **Responsive to High-Priority Tasks**: Immediate CPU allocation to high-priority tasks.
- **Efficient Resource Utilization**: Ensures the CPU is actively working on the most important tasks.
- **Flexibility and Control**: Dynamic adjustment of task priorities for effective workload management.

### Implementation Details

- **Process Structure Enhancements**: Added variables to the `proc` structure for static priority (SP), dynamic priority (DP), running time (RTime), sleeping time (STime), waiting time (WTime), start time, and scheduling count (numScheduled).
- **Priority Calculation**: Functions to calculate dynamic priority and recent behavior index (RBI) based on process activity.
- **Scheduler Modifications**: The scheduler function selects and schedules the process with the highest priority.
- **System Calls**: Added a system call to manually set the priority of a process.

### Copy-On-Write (CoW)

CoW is a memory management technique where processes share the same physical memory until a write operation is performed, at which point a copy of the data is made. This reduces memory usage by avoiding unnecessary duplication of data.

### Benefits

- **Memory Efficiency**: Shared memory pages reduce overall memory usage.
- **Performance Optimization**: Reduces the overhead of creating separate memory copies for each process.

### Implementation Details

- **Page Reference Counting**: Introduced a structure to keep track of the reference count for each page.
- **Page Duplication**: Implemented functions to duplicate pages when a write operation occurs.
- **Page Table Entries**: Defined a new page table entry (PTE_COW) for CoW.
- **Memory Management Modifications**: Adjusted memory allocation, deallocation, and page table management to support CoW.

## Concurrency Simulations

### Cafe Simulation

### Question 1: Average Waiting Time

To calculate the average waiting time, a new variable `w_time` is introduced for each customer. This variable is updated when a barista picks up the order. The code snippet provided calculates the average waiting time by summing the differences between the completion time and the entry time for each order in the simulation. In the given test case, the resulting average waiting time is reported as 2.3 seconds, which can be rounded off to 2 seconds. It is emphasized that with an infinite number of baristas, the waiting time tends toward zero, ensuring there is always a free barista for each order.

### Question 2: Wasted Coffee

The report highlights the concept of wasted coffee concerning customer departures. If a customer leaves before their order is completed, and the preparation has already started, the associated coffee is considered wasted. It is clarified that if a customer departs before the coffee enters the preparation phase, no coffees would be deemed wasted. The code calculates and prints the count of wasted coffees at the conclusion of the simulation.

### Ice Cream Parlor Simulation Strategy

### Question 1: Minimizing Unfulfilled Orders

To enhance the fulfillment of orders, a strategy of prioritizing orders with fewer ingredients can be implemented. By monitoring and reserving ingredients for customers with smaller orders, which require fewer ingredients, the aim is to serve a maximum number of complete orders. When ingredient supply becomes limited, a decision is made to reject orders outright if there is no feasible option for ingredient replenishment.

### Ingredient Replenishment Strategy

To mitigate incomplete orders, a minimum threshold for topping quantity is established. When a topping falls below this threshold, a replenishment process is initiated to maintain sufficient ingredient levels. If a customer arrives when there is a shortage of a specific topping, they are requested to wait until an adequate quantity of toppings is available to complete their order.

### Unserviced Orders Management

Addressing unserviced orders involves optimizing machine timings by considering a coarse parlor-based solution. To make the most of existing resources, a scheduling approach prioritizes orders with the shortest preparation times from the pool of available unprepared customer orders. This allows for the fastest possible service to a maximum number of customers, capitalizing on the availability of machines.

