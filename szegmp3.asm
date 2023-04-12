;Gelson Sze S14

global main
extern printf,system,scanf

section .data
clrstr db "cls",0
inputprompt db "DNA string: ",0
resetprompt db "Do you want to try again? ",0
resetinput times 3 db 0 ;char input + enterkey + 0
dnavar times 33 db 0 ; 30 dna alphabets + terminator + enter key + 0
compdnavar times 31 db 0 ; 30 dna alphabets + 0
rvrsemsg db "Reverse complement: %s", 10,0
rvrsepalindromemsg db "Reverse palindrome? %s",0
yes db "Yes",10,0
no db "No",10,0
nullinputmsg db "Error: Null input",10,0
exceedlengthmsg db "Error: Beyond maximum length",10,0
invalidinputmsg db "Error: Invalid input",10,0
noterminatormsg db "Error: Invalid or no terminator",10,0
errortryaganimsg db "Please try again. ",10,0 
scanfmt db `%[^\n]s`,0
getchar db "%c",0
garbageval db 0

section .text
main:
;system ("cls")
    push clrstr
    call system
    add esp,4
;printf("dna string: ");
newinput:
    push inputprompt
    call printf
    add esp,4
;scanf("%s", &dnavar)
    push dnavar
    push scanfmt
    call scanf
    add esp,8
    
    mov esi, 0
    mov al, 0 ;set flag if . encountered
    
checkinput:
    mov ah, 0 ;flag to check for ACGT input
    
    cmp esi, 31
    je endcheckinput
    
    cmp byte[dnavar+esi], 0 ;null input
    je nullinput
    
    cmp byte[dnavar+esi], 10 ;line feed
    je nullinput
    
    cmp byte[dnavar+esi], 13 ;carriage return
    je nullinput
    
    cmp byte[dnavar+esi], '.' ;check for terminator input
    je setperiodflag
    
    cmp byte[dnavar+esi], 'A'
    je setvalidinputflag
    
    cmp byte[dnavar+esi], 'C'
    je setvalidinputflag
    
    cmp byte[dnavar+esi], 'G'
    je setvalidinputflag
    
    cmp byte[dnavar+esi], 'T'
    je setvalidinputflag
    
returnvalidinput:   
    cmp ah, 0
    je invalidinputerror

    inc esi
    jmp checkinput ;loop
    
setperiodflag:
    mov al, 1
    jmp endcheckinput
    
setvalidinputflag:
    mov ah, 1
    jmp returnvalidinput
    
invalidinputerror:
    push invalidinputmsg
    call printf
    add esp,4
    jmp errortryagain
    
nullinput:
    cmp esi, 0
    je nullinputerror ;if null input
    
    cmp esi, 31
    jl noterminatorerror ;else if no terminator
    
    jmp endcheckinput ;else
    
noterminatorerror:
    push noterminatormsg
    call printf
    add esp,4
    jmp errortryagain
    
nullinputerror:
    push nullinputmsg
    call printf
    add esp,4
    jmp errortryagain
    
exceedlengtherror:
    push exceedlengthmsg
    call printf
    add esp,4
    jmp errortryagain
    
endcheckinput:
    cmp al, 1
    jne exceedlengtherror
    
;esi = index of terminator
;edi = index for reverse mem
    xor edi, edi
    sub esi, 1
reversecomplement:
    cmp esi, 0
    jl endreverse
    
    cmp byte[dnavar+esi], 'A'
    je settoT

    cmp byte[dnavar+esi], 'T'
    je settoA
    
    cmp byte[dnavar+esi], 'C'
    je settoG
    
    cmp byte[dnavar+esi], 'G'
    je settoC
    
returnset:
    inc edi
    dec esi
    jmp reversecomplement
    
settoT:
    mov byte[compdnavar+edi], 'T'
    jmp returnset

settoA:
    mov byte[compdnavar+edi], 'A'
    jmp returnset
    
settoG:
    mov byte[compdnavar+edi], 'G'
    jmp returnset

settoC:
    mov byte[compdnavar+edi], 'C'
    jmp returnset
    
endreverse:

    push compdnavar ;print reverse complement
    push rvrsemsg
    call printf
    add esp,8

    mov esi, 0 ;index
    mov ah, 1 ;set flag true unless not palindrome
 
checkreversepalindrome:
    mov al, [dnavar+esi]
    
    cmp al, '.'
    je endcheckreversepalindrome

    cmp al, byte[compdnavar+esi]
    jne setnonequalflag
    
    inc esi
    jmp checkreversepalindrome
    
setnonequalflag:
    mov ah, 0
    
endcheckreversepalindrome:
    
    cmp ah, 0 ;if not palindrome
    je printnonpalindrome
       
    push yes
    push rvrsepalindromemsg
    call printf
    add esp,8
    jmp promptreset
    
printnonpalindrome:  
    push no
    push rvrsepalindromemsg
    call printf
    add esp,8

promptreset:

flushbuffer:
    push garbageval
    push getchar
    call scanf
    add esp,8
    
    cmp byte[garbageval], 10
    je endflushbuffer
    
    jmp flushbuffer
endflushbuffer:

    push resetprompt
    call printf
    add esp,4

    push resetinput
    push scanfmt
    call scanf
    add esp,8
    
    cmp byte[resetinput], 'y'
    je reset
    jmp terminate
    
errortryagain:
    push errortryaganimsg
    call printf
    add esp,4
    
reset:
    mov esi, 0
emptymem:
    cmp esi, 30
    je endemptymem
    mov byte[dnavar+esi], 0
    mov byte[compdnavar+esi], 0
    
    inc esi
    jmp emptymem
    
endemptymem:
    mov byte[dnavar+30], 0 ;clear terminator 
    mov byte[resetinput], 0 ;clear resetinput
    
flushbuffer2:
    push garbageval
    push getchar
    call scanf
    add esp,8
    
    cmp byte[garbageval], 10
    je endflushbuffer2
    
    jmp flushbuffer
    
endflushbuffer2:    
    jmp newinput
    
terminate:    
    xor eax, eax
    ret