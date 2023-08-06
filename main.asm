assume cs:code,ds:data
data segment
    begin db "start game",0
    history db "history",0
    snake db 20,3,21,3,22,3,23,3,24,3,25,3,26,3,27,3;坐标范围25X80 0000 0000
    len dw 14
    food db 0,0
    fd_live db 0
    socre dw 0
    speed dw 0
data ends

code segment
    start:
    mov ax,data
    mov ds,ax
    ;清屏
    mov ax,0B800h
    mov es,ax
    mov bx,0
    mov cx,2000
    cls:
        mov byte ptr al,32
        mov byte ptr es:[bx],al
        mov es:[bx+1],0
        add bx,2
        loop cls
        
    mov bx,0
    mov si,0
    ;屏幕显示开始游戏
    outbegin:
    mov byte ptr al,begin[bx]
    mov es:[160*11+80+si],al
    inc bx
    add si,2
    cmp begin[bx],0
    jne outbegin

    ;设置键盘中断，输入enter进入   
    waitenter:
    mov ah,0;0号模式，读取键盘缓冲区
    int 16h
    cmp ah,1ch;enter的扫描码
    je game
    jmp waitenter

    game:
    ;清屏
    mov bx,0
    mov cx,2000
    cls1:
        mov al,32
        mov byte ptr es:[bx],al
        mov es:[bx+1],0
        add bx,2
        loop cls1
    ;设置围墙
    mov bx,0;左上角
    mov cx,80
    mov si,0
    upper: ;绘制围墙顶部和尾部
        mov al,197
        mov ah,00000010b
        mov es:[bx],ax
        mov es:[3840+bx],ax
        add bx,2
        loop upper
    mov bx,0
    mov cx,25
    side:   
        mov al,197
        mov ah,00000010b
        mov es:[bx],ax
        mov es:[bx+158],ax
        add bx,160
        loop side
    eatfood:
        cmp fd_live,0
        je randfood
        mov al,food[0]
        mov ah,snake[0]
        cmp ah,al
        jne darwfood
        mov al,food[1]
        mov ah,snake[1]
        cmp ah,al
        jne darwfood
        mov fd_live,0
    randfood:
        cmp fd_live,0;食物存在则不生成
        jne darwfood
        ;随机X坐标,si存放:2*x,di存放:,160*y
        mov ax,0
        mov si,ax
        mov di,ax
        randx:
        mov ax,80
        out 41h,al
        in al,40h
        mov ah,0
        cmp ax,80
        ja randx
        cmp ax,0
        je randx
        mov food[0],al
        

        ;随机Y坐标
        randy:
        mov ax,25
        out 41h,al
        in al,40h
        mov ah,0
        cmp ax,0
        je randy
        cmp ax,23
        ja randy
        mov food[1],al
       
    
    
    darwfood:
        mov bl,food[0]
        mov al,2
        mul bl ;结果在ax
        push ax
        ;y*160
        mov bh,food[1]
        mov al,160
        mul bh
        ;合成为偏移地址
        pop bx
        add ax,bx
        mov si,ax
        mov byte ptr es:[si],32
        mov es:[si+1],00100000b
        mov fd_live,1
    
    drawsnake:
        ;绘制蛇关节
        mov si,0;指向蛇头
        axis:
            ;x*2
            mov bl,snake[si]
            mov al,2
            mul bl ;结果在ax
            push ax
            ;y*160
            mov bh,snake[si+1]
            mov al,160
            mul bh
            ;合成为偏移地址
            pop bx
            add ax,bx
            mov di,ax
           
            ;蛇头设置为红色
            mov ax,00010000b;al控制颜色,0001 0000b为蓝色
            cmp si,0
            jne drawjoint;
            shl ax,1;
            ;绘制关节
            drawjoint:
                shl ax,1;左移动
                mov es:[di],32
                mov es:[di+1],al;00100000b--green 01000000b-red,红色左移两位，绿色左移一位
                add si,2
                cmp si,len
                jne axis
    
    

    
    
    exist:
        cmp snake[0],0
        jna gameover
        cmp snake[0],79
        ja gameover
        cmp snake[1],0
        jna gameover
        cmp snake[1],25
        ja gameover
   
    ;扫描键盘
    scankeybd:
        mov ah,0
        int 16h;调用中断，等待输入
        cmp al,'d'
        je snakeright
        cmp al,'a'
        je snakeleft
        cmp al,'s'
        je snakedown
        cmp al,'w'
        je snakeup
        jmp scankeybd

    snakeup:
        mov bx,len;0,1,2,3
        sub bx,2;bx=len-3
        mov si,len;bx=len-2
        sub si,1
         traveu:
            mov al,snake[bx-2]
            mov snake[bx],al
            sub bx,2
            mov al,snake[si-2]
            mov snake[si],al
            sub si,2
           
            cmp bx,0
            jne traveu
        ;蛇头
        headu:
        mov al,1;坐标+1
        sbb snake[1],al
        jmp game


    
    snakedown:
        mov bx,len;0,1,2,3
        sub bx,2;bx=len-3
        mov si,len;bx=len-2
        sub si,1
         traved:
            mov al,snake[bx-2]
            mov snake[bx],al
            sub bx,2
            mov al,snake[si-2]
            mov snake[si],al
            sub si,2
           
            cmp bx,0
            jne traved
        ;蛇头
        headd:
        add snake[1],1
        mov ax,0B800h
        mov es,ax
        mov bx,0
        mov cx,2000
       
        jmp game

    snakeright:
         mov bx,len;0,1,2,3
        sub bx,2;bx=len-3
        mov si,len;bx=len-2
        sub si,1
         traver:
            mov al,snake[bx-2]
            mov snake[bx],al
            sub bx,2
            mov al,snake[si-2]
            mov snake[si],al
            sub si,2
           
            cmp bx,0
            jne traver
        ;蛇头
        headr:
        mov al,1;坐标+1
        add snake[0],al
        jmp game
    snakeleft:
        mov bx,len;0,1,2,3
        sub bx,2;bx=len-3
        mov si,len;bx=len-2
        sub si,1
         travel:
            mov al,snake[bx-2]
            mov snake[bx],al
            sub bx,2
            mov al,snake[si-2]
            mov snake[si],al
            sub si,2
           
            cmp bx,0
            jne travel
        ;蛇头
        headl:
        mov al,1;坐标+1
        sub snake[0],al
        jmp game
   
    gameover:
         mov bx,0
         mov cx,2000
        cls2:
            mov al,32
            mov byte ptr es:[bx],al
            mov es:[bx+1],0
            add bx,2
            loop cls2

   
code ends
end start