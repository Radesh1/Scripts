#!/bin/bash
#funções do corpo.sh
testedependencias(){ 
dpkg --get-selections | grep zenity
if [ "$?" -eq "0" ];
then echo " "
else echo "Instalando dependencia necessaria pacote Zenity"
sleep 2
apt-get install zenity -y

fi

dpkg --get-selections | grep openssl
if [ "$?" -eq "0" ];
then echo " "
else echo "Instalando dependencia necessaria pacote openssl"
sleep 2
apt-get install openssl -y

fi
}

modECB(){

keysize=$(zenity --list --title "Modo de operação ECB" --text "Selecione o tamanho da chave" --radiolist --column "  " --column "Size" TRUE "128" FALSE "256")

		opcao1=$(zenity --list --title "Selecione uma das opções abaixo!" --width=600 --height=380 --column id --column Descrição 1 "Criptografar usando uma chave armazenada em um arquivo (formato hexadecimal)" 2 "Criptografar derivando a chave de uma senha" 3 "Criptografar com uma chave pseudorandômica")

		if [ $opcao1 == "1" ]
			then
				file=$(zenity --title "Selecione o arquivo que será cifrado!" --width=650 --height=380 --file-selection )
				aux=$(zenity --title "Selecione o arquivo com a chave criptográfica!" --width=650 --height=380 --file-selection )
				key=$(head -1 $aux)
				zenity --info --text "Selecione o diretório para salvar o arquivo cifrado"
				savedir=$(zenity --file-selection --save)

				openssl enc -aes-$keysize-ecb -in $file -out $savedir -K $key

				zenity --info --text "ARQUIVO CRIPTOGRAFADO!"				
		fi
		

		if [ $opcao1 == "2" ]
			then
				file=$(zenity --title "Selecione o arquivo que será cifrado!" --width=650 --height=380 --file-selection )
				zenity --info --text "A seguir, informe a senha que será usada na derivação da chave.\nOBS:Guarde essa senha pois sem ela não há como descriptografar!"
				senha=$(zenity --forms --add-password "Digite a senha")
				
				if [ $keysize == "128" ]
					then
						key=$(echo -n $senha | md5sum | cut -d' ' -f1)
					else
						key=$(echo -n $senha | sha256sum | cut -d' ' -f1)
				fi

				zenity --info --text "Selecione o diretório para salvar o arquivo cifrado"
				savedir=$(zenity --file-selection --save)

				openssl enc -aes-$keysize-ecb -in $file -out $savedir -K $key
				zenity --info --text "ARQUIVO CRIPTOGRAFADO!"
		fi


		if [ $opcao1 == "3" ]
			then
			file=$(zenity --title "Selecione o arquivo que será cifrado!" --width=650 --height=380 --file-selection )
			aux=$[$keysize/8]	
			key=$(openssl rand -hex $aux)
			zenity --info --text "Selecione o diretório para salvar o arquivo cifrado"
			savedir=$(zenity --file-selection --save)
			openssl enc -aes-$keysize-ecb -in $file -out $savedir -K $key
			echo $key > k.ENC.txt
			zenity --info --text "ARQUIVO CRIPTOGRAFADO!\n\nOBS: A chave usada para cifrar e decifrar, se encontram na pasta do projeto!"
		fi


		

}





modCBC(){
keysize=$(zenity --list --title "Modo de operação CBC" --text "Selecione o tamanho da chave" --radiolist --column "  " --column "Size" TRUE "128" FALSE "256")


		opcao1=$(zenity --list --title "Selecione uma das opções abaixo!" --width=600 --height=380 --column id --column Descrição 1 "Criptografar usando uma chave armazenada em um arquivo (formato hexadecimal)" 2 "Criptografar derivando a chave de uma senha" 3 "Criptografar com uma chave pseudorandômica")

		if [ $opcao1 == "1" ]
			then
				file=$(zenity --title "Selecione o arquivo que será cifrado!" --width=650 --height=380 --file-selection )
				aux=$(zenity --title "Selecione o arquivo com a chave criptográfica!" --width=650 --height=380 --file-selection )
				aux1=$(zenity --title "Selecione o arquivo com o vetor inicial!" --width=650 --height=380 --file-selection )
				key=$(head -1 $aux)
				iv=$(head -1 $aux1)
				zenity --info --text "Selecione o diretório para salvar o arquivo cifrado"
				savedir=$(zenity --file-selection --save)

				openssl enc -aes-$keysize-cbc -in $file -out $savedir -K $key -iv $iv

				zenity --info --text "ARQUIVO CRIPTOGRAFADO!"				
		fi
		

		if [ $opcao1 == "2" ]
			then
				file=$(zenity --title "Selecione o arquivo que será cifrado!" --width=650 --height=380 --file-selection )
				zenity --info --text "A seguir, informe a senha que será usada na derivação da chave.\nOBS:Guarde essa senha pois sem ela não há como descriptografar!"
				senha=$(zenity --forms --add-password "Digite a senha")
				
				if [ $keysize == "128" ]
					then
						key=$(echo -n $senha | md5sum | cut -d' ' -f1)
						zenity --info --text "Selecione o diretório para salvar o arquivo cifrado"
						savedir=$(zenity --file-selection --save)

						openssl enc -aes-$keysize-cbc -in $file -out $savedir -K $key -iv $key

						zenity --info --text "ARQUIVO CRIPTOGRAFADO!"

					else
						key=$(echo -n $senha | sha256sum | cut -d' ' -f1)
						iv=$(echo -n $senha | md5sum | cut -d' ' -f1)

						zenity --info --text "Selecione o diretório para salvar o arquivo cifrado"
						savedir=$(zenity --file-selection --save)

						openssl enc -aes-$keysize-cbc -in $file -out $savedir -K $key -iv $iv

						zenity --info --text "ARQUIVO CRIPTOGRAFADO!"
				fi
		fi


		if [ $opcao1 == "3" ]
			then
			file=$(zenity --title "Selecione o arquivo que será cifrado!" --width=650 --height=380 --file-selection )
			aux=$[$keysize/8]	
			key=$(openssl rand -hex $aux)
			iv=$(openssl rand -hex 16)
			
			zenity --info --text "Selecione o diretório para salvar o arquivo cifrado"
			savedir=$(zenity --file-selection --save)

			openssl enc -aes-$keysize-cbc -in $file -out $savedir -K $key -iv $iv

			echo $key > k.ENC.txt
			echo $iv > iv.ENC.txt

			zenity --info --text "ARQUIVO CRIPTOGRAFADO!\n\nOBS: A chave e o vetor inicial usados para cifrar e decifrar, se encontrão na pasta do projeto!"
		fi	




}


decryptECB(){

opcao1=$(zenity --list --title "Selecione uma das opções abaixo!" --width=600 --height=380 --column id --column Descrição 1 "Descriptografar usando uma chave armazenada em um arquivo (formato hexadecimal)" 2 "Descriptografar derivando a chave de uma senha")

                if [ $opcao1 == "1" ]
                        then

keysize=$(zenity --title="Tamanho da chave" --text "Digite o tamanho da chave 128-256!" --entry)
zenity --info --text "selecione o arquivo que sera decifrado"
                                file=$(zenity --title "Selecione o arquivo que será decifrado!" --width=650 --height=380 --file-selection )
zenity --info --text "selecione a chave"
                                aux=$(zenity --title "Selecione o arquivo com a chave criptográfica!" --width=650 --height=380 --file-selection )
                                key=$(head -1 $aux)
                                zenity --info --text "Selecione o diretório para salvar o arquivo decifrado"
                                savedir=$(zenity --file-selection --save)

                                openssl enc -aes-$keysize-ecb -in $file -out $savedir -K $key -d

zenity --info --text "ARQUIVO DESCRIPTOGRAFADO!"
                fi

if [ $opcao1 == "2" ]
                        then

keysize=$(zenity --title="Tamanho da chave" --text "Digite o tamanho da chave 128-256!" --entry)


                                file=$(zenity --title "Selecione o arquivo que será decifrado!" --width=650 --height=380 --file-selection )
                                zenity --info --text "A seguir, informe a senha que será usada para decifrar o arquivo!"
                                senha=$(zenity --forms --add-password "Digite a senha")
if [ $keysize == "128" ]
                                        then
                                                key=$(echo -n $senha | md5sum | cut -d' ' -f1)
                                        else
                                                key=$(echo -n $senha | sha256sum | cut -d' ' -f1)
                                fi

                                zenity --info --text "Selecione o diretório para salvar o arquivo decifrado"
                                savedir=$(zenity --file-selection --save)
 openssl enc -aes-$keysize-ecb -in $file -out $savedir -K $key -d
                                zenity --info --text "ARQUIVO DESCRIPTOGRAFADO!"
                fi

}



decryptCBC(){

opcao1=$(zenity --list --title "Selecione uma das opções abaixo!" --width=600 --height=380 --column id --column Descrição 1 "Descriptografar usando uma chave armazenada em um arquivo (formato hexadecimal)" 2 "Descriptografar derivando a chave de uma senha")

                if [ $opcao1 == "1" ]
                        then
keysize=$(zenity --title="Tamanho da chave" --text "Digite o tamanho da chave 128-256!" --entry)

zenity --info --text "selecione o arquivo que será decifrado"

				    file=$(zenity --title "Selecione o arquivo que será decifrado!" --width=650 --height=380 --file-selection )
zenity --info --text "selecione a chave"
                                aux=$(zenity --title "Selecione o arquivo com a chave criptográfica!" --width=650 --height=380 --file-selection )
zenity --info --text "selecione o IV"

                                aux2=$(zenity --title "Selecione o arquivo com o vetor inicial!" --width=650 --height=380 --file-selection )

                                key=$(head -1 $aux)
                                iv=$(head -1 $aux2)
                                zenity --info --text "Selecione o diretório para salvar o arquivo decifrado"
                                savedir=$(zenity --file-selection --save)

                                openssl enc -aes-$keysize-cbc -in $file -out $savedir -K $key -iv $iv -d
zenity --info --text "ARQUIVO DESCRIPTOGRAFADO!" 
                fi

                if [ $opcao1 == "2" ]
                        then
keysize=$(zenity --title="Tamanho da chave" --text "Digite o tamanho da chave 128-256!" --entry)


                                file=$(zenity --title "Selecione o arquivo que será decifrado!" --width=650 --height=380 --file-selection )
                                zenity --info --text "A seguir, informe a senha que será usada para decifrar o arquivo!"
                                senha=$(zenity --forms --add-password "Digite a senha")

                                if [ $keysize == "128" ]
                                        then
                                                key=$(echo -n $senha | md5sum | cut -d' ' -f1)
                                                zenity --info --text "Selecione o diretório para salvar o arquivo decifrado"
                                                savedir=$(zenity --file-selection --save)
                                                openssl enc -aes-$keysize-cbc -in $file -out $savedir -K $key -iv $key -d

                                                zenity --info --text "ARQUIVO DESCRIPTOGRAFADO!"
                                        else
                                                key=$(echo -n $senha | sha256sum | cut -d' ' -f1)
                                                iv=$(echo -n $senha | md5sum | cut -d' ' -f1)
                                                zenity --info --text "Selecione o diretório para salvar o arquivo decifrado"

savedir=$(zenity --file-selection --save)

                                                openssl enc -aes-$keysize-cbc -in $file -out $savedir -K $key -iv $iv -d

                                                zenity --info --text "ARQUIVO DESCRIPTOGRAFADO!"
                                fi
                fi


       
}
