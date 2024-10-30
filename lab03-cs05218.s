# a0 - img  // byte pointer
# a1 - columns
# a2 - rows
# a3 - out  // half-word pointer
# for t0 = 0 to row-1
#   for t1 = 0 to column-1
#      r = *img
#      r = (r & 0xf8) << 8  # clear 3 LSb and shift to its final position
#      g = *(img+1)
#      g = (g & 0xfc) << 3 # clear 2 LSb and shift to its final position
#      b = *(img+2)
#      b = b >> 3 # Remove 3 LSb and shift to its position - two birds with one stone
       /* Alternative code. Probably simpler to understand.
#      r = r >> 3  # upper bits are 0, no need to mask
#      g = g >> 2  # upper bits are 0, no need to mask
#      b = b >> 3  # upper bits are 0, no need to mask
#      rgb = (r << 11) | (g << 5) | b
       */
#      *out = rgb  // half-word store
#      img += 3  // move to next pixel
#      out += 1  // move to next half-word
#   endfor
# endfor
.globl rgb888_to_rgb565, showImage

.data

image888:  # A rainbow-like image Red->Green->Blue->Red
    .byte 255, 0,     0
    .byte 255,  85,   0
    .byte 255, 170,   0
    .byte 255, 255,   0
    .byte 170, 255,   0
    .byte  85, 255,   0
    .byte   0, 255,   0
    .byte   0, 255,  85
    .byte   0, 255, 170
    .byte   0, 255, 255
    .byte   0, 170, 255
    .byte   0,  85, 255
    .byte   0,   0, 255
    .byte  85,   0, 255
    .byte 170,   0, 255
    .byte 255,   0, 255
    .byte 255,   0, 170
    .byte 255,   0,  85
    .byte 255,   0,   0
# repeat the above 5 times
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
    .byte 255, 0,     0, 255,  85,   0 255, 170,   0, 255, 255,   0, 170, 255,   0, 85, 255,   0, 0, 255,   0, 0, 255,  85, 0, 255, 170, 0, 255, 255, 0, 170, 255, 0,  85, 255, 0,   0, 255, 85,   0, 255, 170,   0, 255, 255,   0, 255, 255,   0, 170, 255,   0,  85, 255,   0,   0
image565:
    .zero 512  # leave a 1Kibyte free space

image888_back:
    .zero 512

.text
# -------- This is just for fun.
# Ripes has a LED matrix in I/O tab. To enable it:
# - Go to the I/O tab and double click on LED Matrix.
# - Change the Height and Width (at top-right part of I/O window),
#     to the size of the image888 (19, 6 in this example)
# - This will enable the LED matrix
# - Uncomment the following and you should see the image on the LED matrix!
#    la   a0, image888
#    li   a1, LED_MATRIX_0_BASE
#    li   a2, LED_MATRIX_0_WIDTH
#    li   a3, LED_MATRIX_0_HEIGHT
#    jal  ra, showImage
# ----- This is where the fun part ends!

    la   a0, image888
    la   a3, image565
    li   a1, 19 # width
    li   a2,  6 # height
    jal  ra, rgb888_to_rgb565

# convert it back to RGB888.
#  However some colours will be different now
#  (the lsbs were lost when the image was converted to RGB565!
    la   a0, image565
    la   a3, image888_back
    li   a1, 19 # width
    li   a2,  6 # height
    jal  ra, rgb565_to_rgb888

# Display it  - uncomment and enable LED Matrix as descibed above 
#    la   a0, image888_back
#    li   a1, LED_MATRIX_0_BASE
#    li   a2, LED_MATRIX_0_WIDTH
#    li   a3, LED_MATRIX_0_HEIGHT
#    jal  ra, showImage

    addi a7, zero, 10 
    ecall

# ----------------------------------------
# Subroutine showImage
# a0 - image to display on Ripes' LED matrix
# a1 - Base address of LED matrix
# a2 - Width of the image and the LED matrix
# a3 - Height of the image and the LED matrix
# Caution: Assumes the image and LED matrix have the
# same dimensions!
showImage:
    add  t0, zero, zero # row counter
showRowLoop:
    bge  t0, a3, outShowRowLoop
    add  t1, zero, zero # column counter
showColumnLoop:
    bge  t1, a2, outShowColumnLoop
    lbu  t2, 0(a0) # get red
    lbu  t3, 1(a0) # get green
    lbu  t4, 2(a0) # get blue
    slli t2, t2, 16  # place red at the 3rd byte of "led" word
    slli t3, t3, 8   #   green at the 2nd
    or   t4, t4, t3  # combine green, blue
    or   t4, t4, t2  # Add red to the above
    sw   t4, 0(a1)   # let there be light at this pixel
    addi a0, a0, 3   # move on to the next image pixel
    addi a1, a1, 4   # move on to the next LED
    addi t1, t1, 1
    j    showColumnLoop
outShowColumnLoop:
    addi t0, t0, 1
    j    showRowLoop
outShowRowLoop:
    jalr zero, ra, 0
# ----------------------------------------

rgb888_to_rgb565:
    add  t0, zero, zero # row counter
rowLoop:
    bge  t0, a2, outRowLoop
    add  t1, zero, zero # column counter
columnLoop:
    bge  t1, a1, outColumnLoop
    lbu  t2, 0(a0)   # r
    lbu  t3, 1(a0)   # g
    lbu  t4, 2(a0)   # b
    andi t2, t2, 0xf8   # clear 3 lsbs
    slli t2, t2, 8      # shift to final place of R in RGB565 format
    andi t3, t3, 0xfc   # clear 2 lsbs
    slli t3, t3, 3      # shift to final place of G in RGB565 format
    srli t4, t4, 3      # remove 3 lsbs of blue
    or   t2, t2, t3
    or   t2, t2, t4
    sh   t2, 0(a3)   # store 16bits (half word) in RGB565 format to output
    addi a0, a0, 3   # move input pointer to next pixel
    addi a3, a3, 2   # move ouput pointer to next pixel
    addi t1, t1, 1
    j    columnLoop
outColumnLoop:
    addi t0, t0, 1
    j    rowLoop
outRowLoop:
    jalr zero, ra, 0



rgb565_to_rgb888:
    add  t0, zero, zero # row counter
rowl:
    bge  t0, a2, outRowl
    add  t1, zero, zero # column counter
columnl:
    bge  t1, a1, outColumnl
    lhu  t2, 0(a0)
    srli t3, t2, 8  # extract red (3 lsbs still from green)
    andi t3, t3, 0xf8 # clear 3 lsbs
    sb   t3, 0(a3) # store in out image
    srli t3, t2, 3  # extract green (2 lsbs still from blue)
    andi t3, t3, 0xfc # clear 2 lsbs
    sb   t3, 1(a3) # store in out image
    slli t3, t2, 3
    andi t3, t3, 0xf8 # clear 3 lsbs
    sb   t3, 3(a3) # store in out image
    addi a0, a0, 2   # move input pointer to next pixel
    addi a3, a3, 3   # move ouput pointer to next pixel
    addi t1, t1, 1
    j    columnl
outColumnl:
    addi t0, t0, 1
    j    rowl
outRowl:
    jalr zero, ra, 0
