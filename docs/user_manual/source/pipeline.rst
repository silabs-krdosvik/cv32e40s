.. _pipeline-details:

.. figure:: ../images/CV32E40S_Pipeline.png
   :name: |corev_lc|\ -pipeline
   :align: center

   |corev| Pipeline

Pipeline Details
================

|corev| has a 4-stage in-order completion pipeline, the 4 stages are:

Instruction Fetch (IF)
  Fetches instructions from memory via an aligning prefetch buffer, capable of fetching 1 instruction per cycle if the instruction side memory system allows. The IF stage also pre-decodes RVC instructions into RV32I base instructions. See :ref:`instruction-fetch` for details.

Instruction Decode (ID)
  Decodes fetched instruction and performs required register file reads. Jumps are taken from the ID stage.

Execute (EX)
  Executes the instructions. The EX stage contains the ALU, Multiplier and Divider. Branches (with their condition met) are taken from the EX stage. Multi-cycle instructions will stall this stage until they are complete. The address generation part of the load-store-unit (LSU) is contained in EX as well.

Writeback (WB)
  Writes the result of ALU, Multiplier, Divider, or Load instructions instructions back to the register file.

Multi- and Single-Cycle Instructions
------------------------------------

:numref:`Cycle counts per instruction type` shows the cycle count per instruction type. Some instructions have a variable time, this is indicated as a range e.g. 1..32 means
that the instruction takes a minimum of 1 cycle and a maximum of 32 cycles. The cycle counts assume zero stall on the instruction-side interface
and zero stall on the data-side memory interface.

.. table:: Cycle counts per instruction type
  :name: Cycle counts per instruction type
  :widths: 10 10 80
  :class: no-scrollbar-table

  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  |   Instruction Type    |                 Cycles               |                         Description                         |
  +=======================+======================================+=============================================================+
  | Integer Computational | 1                                    | Integer Computational Instructions are defined in the       |
  |                       |                                      | RISCV-V RV32I Base Integer Instruction Set.                 |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | CSR Access            | 4 (``jvt``, ``cpuctrl``, ``pmp*``    | CSR Access Instruction are defined in 'Zicsr' of the        |
  |                       |    ``secureseed*``, ``mseccfg``,     |                                                             |
  |                       |    ``mstateen0``                     |                                                             |
  |                       |                                      | RISC-V specification.                                       |
  |                       | 1 (all the other CSRs)               |                                                             |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | Load/Store            | 1                                    | Load/Store is handled in 1 bus transaction using both EX    |
  |                       |                                      | and WB stages for 1 cycle each. For misaligned word         |
  |                       | 2 (non-word aligned word             | transfers and for halfword transfers that cross a word      |
  |                       | transfer)                            | boundary 2 bus transactions are performed using EX and WB   |
  |                       |                                      | stages for 2 cycles each.                                   |
  |                       | 2 (halfword transfer crossing        |                                                             |
  |                       | word boundary)                       |                                                             |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | Multiplication        | 1 (``mul``)                          | |corev| uses a single-cycle 32-bit x 32-bit multiplier      |
  |                       |                                      | with a 32-bit result. The multiplications with upper-word   |
  |                       | 4 (``mulh``, ``mulhsu``, ``mulhu``)  | result take 4 cycles to compute.                            |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | Division              | 3 - 35                               | The number of cycles depends on the divider operand value   |
  |                       |                                      | (operand b), i.e. in the number of leading bits at 0.       |
  | Remainder             | 3 - 35                               | The minimum number of cycles is 3 when the divider has zero |
  |                       |                                      | leading bits at 0 (e.g., 0x8000000).                        |
  |                       | 35 (cpuctrl.dataindtiming is set)    | The maximum number of cycles is 35 when the divider is 0    |
  |                       |                                      |                                                             |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | Jump                  | 2 (PC hardening disabled)            | Jumps are performed in the ID stage. Upon a jump the IF     |
  |                       |                                      | stage (including prefetch buffer) is flushed. The new PC    |
  |                       | 3 (target is a non-word-aligned      | request will appear on the instruction-side memory          |
  |                       | non-RVC instruction, PC hardening    | interface the same cycle the jump instruction is in the ID  |
  |                       | disabled)                            | stage.                                                      |
  |                       |                                      |                                                             |
  |                       | 3 (PC hardening enabled)             |                                                             |
  |                       |                                      |                                                             |
  |                       | 4 (target is a non-word-aligned      |                                                             |
  |                       | non-RVC instruction, PC hardening    |                                                             |
  |                       | enabled)                             |                                                             |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | mret                  | 2 (PC hardening disabled)            | Mret is performed in the ID stage. Upon an mret the IF      |
  |                       |                                      | stage (including prefetch buffer) is flushed. The new PC    |
  |                       | 3 (target is a non-word-aligned      | request will appear on the instruction-side memory          |
  |                       | non-RVC instruction, PC hardening    | interface the same cycle the mret instruction is in the ID  |
  |                       | disabled)                            | stage.                                                      |
  |                       |                                      |                                                             |
  |                       | 3 (PC hardening enabled)             |                                                             |
  |                       |                                      |                                                             |
  |                       | 4 (target is a non-word-aligned      |                                                             |
  |                       | non-RVC instruction, PC hardening    |                                                             |
  |                       | enabled)                             |                                                             |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | Branch (Not-Taken)    | 1                                    | Any branch where the condition is not met will              |
  | PC hardening disabled |                                      | not stall.                                                  |
  |                       | 3 (cpuctrl.dataindtiming is set)     |                                                             |
  |                       |                                      |                                                             |
  |                       | 4 (cpuctrl.dataindtiming is set and  |                                                             |
  |                       | target is a non-word-aligned         |                                                             |
  |                       | non-RVC instruction)                 |                                                             |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | Branch (Not-Taken)    | 2                                    | Any branch where the condition is not met will              |
  | PC hardening enabled  |                                      | not stall.                                                  |
  |                       | 3 (cpuctrl.dataindtiming is set)     |                                                             |
  |                       |                                      |                                                             |
  |                       | 4 (cpuctrl.dataindtiming is set and  |                                                             |
  |                       | target is a non-word-aligned         |                                                             |
  |                       | non-RVC instruction)                 |                                                             |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | Branch (Taken)        | 3                                    | The EX stage is used to compute the branch decision. Any    |
  |                       |                                      | branch where the condition is met will be taken from  the   |
  |                       | 4 (target is a non-word-aligned      | EX stage and will cause a flush of the IF stage (including  |
  |                       | non-RVC instruction)                 | prefetch buffer) and ID stage.                              |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | ``fence.i``           | 5                                    | The ``fence.i`` instruction is defined in 'Zifencei' of the |
  |                       |                                      | RISC-V specification. Internally it is implemented as a     |
  |                       | 6 (target is a non-word-aligned      | jump to the instruction following the fence. The jump       |
  |                       | non-RVC instruction)                 | performs the required flushing as described above.          |
  |                       |                                      | A ``fence.i`` instruction will not complete until           |
  |                       |                                      | the external handshake has been completed.                  |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | ``fence``             | 5                                    | The ``fence`` instruction is implemented as a jump to the   |
  |                       |                                      | instruction instruction following the fence.                |
  |                       | 6 (target is a non-word-aligned      |                                                             |
  |                       | non-RVC instruction)                 |                                                             |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | Zba, Zbb, Zbc, Zbs    | 1                                    | All instructions from Zba, Zbb, Zbc, Zbs take 1 cycle.      |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | Zcmt                  | 2 (PC hardening disabled)            | Table jumps take 2 cycles without PC hardening.             |
  |                       |                                      |                                                             |
  |                       | 4 (PC hardening enabled)             |                                                             |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | Zcmp                  | 2 - 18 (PC hardening disabled)       | The number of cycles depends on the number of registers     |
  |                       |                                      | saved or restored by the instructions.                      |
  |                       | 2 - 19 (PC hardening enabled)        |                                                             |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | Zca, Zcb              | 1                                    | Instructions from Zca and Zcb take 1 cycle.                 |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+
  | ``wfi``, ``wfe``      | 2 -                                  | Instructions causing sleep will not retire until wakeup.    |
  +-----------------------+--------------------------------------+-------------------------------------------------------------+


Hazards
-------

The |corev| experiences a 1 cycle penalty on the following hazards.

 * Load data hazard (in case the instruction immediately following a load uses the result of that load).
 * Jump register (``jalr``) data hazard (in case that a ``jalr`` depends on the result of an immediately preceding non-load instruction).
 * An instruction causing an implicit CSR read in ID (``mret``, ``wfi``, ``wfe`` or table jump) while a CSR access instruction or an instruction causing an implicit CSR access is in the WB stage.
 * An instruction causing an implicit CSR read in EX while a CSR access instruction or an instruction causing an implicit CSR access is in the WB stage.
 * An instruction causing an explicit CSR read in EX while an instruction causing an implicit CSR write is in the WB stage.
 * An instruction causing an explicit CSR read in EX while there is a RAW hazard with an explicit CSR write in WB.

The |corev| experiences a 2 cycle penalty on the following hazards.

 * Jump register (``jalr``) data hazard (in case that a ``jalr`` depends on the result of an immediately preceding load instruction).
 * An instruction causing an implicit CSR read in ID (``mret``, ``wfi``, ``wfe``  or table jump) while a CSR access instruction or an instruction causing an implicit CSR access is in the EX stage.

.. note::
  Implicit CSR reads are reads performed by non-CSR instructions or CSR instructions reading CSR values from another CSR.
  Explicit CSR reads and writes are CSR instructions accessing the CSR encoded in the instruction word.
