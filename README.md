# Encryption Algorithm

## Description
This program encrypts a file using a degree 2 formula and  
then decrypts the file using another degree 2 formula.

## Files
| File               | Language | Library | Description                                   |
|--------------------|:--------:|---------|-----------------------------------------------|
| Encrypt_CUDA       | C        | CUDA    | Processes information on GPU threads          |
| Encrypt_SERIAL     | C        |         | Processes information serially on one process |

## About

I'm going to not change the names on each individual file so  
the program should compile without any issue once loaded into  
Schooner. Hopefully this helps. Feel free to test with this  
readme.txt file also by ./encrypt readme.txt > out.txt  

## Executing Program

<Encrypts regular file without calling N characters>  
./encrypt [filename]  

	or  

<Encrypts a string of 2^N zeros for easy readability>  
./encrypt -n [1:20]  

## Visualizing Program

Setting the Debug global variable to 1 shows all output and  
allows for readability.  

*WARNING*  
Running the current batch with debug on will run the terminal  
out of character space and will not be readable. For use on  
small sets of zeros or minimal files.  

## Enclosed Files
encrypt.cu 	<Program Source Code>
README.md		<This file>
