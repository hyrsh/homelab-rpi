# Extended information

These kinds of pages do provide a bit more knowledge about specific topics but are not necessary to continue with the project.

<hr>

## Local storage

The SBC Raspberry Pi does act as a computing unit like a server, thin/fat client or PC and needs some local storage to persist configurations about the system and its services.

In general there are things like [overlay filesystems](https://www.kernel.org/doc/html/latest/filesystems/overlayfs.html) but they are ephemeral and cannot persist data beyond a restart of the machine.

This is why we need a local peristent storage (here we use microSD cards) and try to make it last as long as possible by keeping local data at a minimum.

<hr>

### SD cards & Flash memory

The storage architecture of a microSD card is called "flash memory" and consists of a great number of cells that can hold information.

To store information in a cell it needs to be erased and flashed (programmed) with a new value (this is called a P/E cycle). This operation does wear the cell out since it is an electrical charge that is applied. For a single cell to go bad there is a rule of thumb that suggests that after ~100.000 P/E cycles the data in that cell will become unreliable upon retrieval.

There are certain mechanisms in place to enhance the durability of a flash memory storage device. One of them is called "wear leveling" which distributes P/E cycles evenly across all existing cells.

This simple fact caught my attention since it means that a bigger pool of cells would scale linear in durability when using the same storage amount.

<hr>

### Idea of a simpleton

Let's say we need a total of 4GB of local storage and have a 16GB microSD card:

- since we are running an OS on it there are many operations that permanently create P/E cycles
- solid/stable data does not change much and therefore is very gentle with P/E cycles
- local data does not grow beyond 5GB in ~1yr (including logs, local container images etc)
- temperature is mostly stable
- no physical damage is expected

If this microSD card would have an approximate lifetime expectancy of about 2yrs given the circumstances, we could assume the following linear scale:

- 32GB microSD card => 4yrs EOL
- 64GB microSD card => 8yrs EOL
- 128GB microSD card => 16yrs EOL

Of course this is just a simple calculation and does not have any scientific validation but the main idea is to have more cells and fewer storage to let "wear leveling" do its thing and give it more space (available cells) to work.



