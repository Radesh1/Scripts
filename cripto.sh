#!/bin/bash/

source libcripto.sh

EXEC(){
		opmod=$(zenity --list --title "Cifras" --text "Selecione uma opção" --radiolist --column "  " --column "Encrypt/Decrypt" 1 "Encryptar" 2 "Decryptar")

	if [ $opmod == "Encryptar" ]
        	then
                modENCRYPT
        	else
                modDECRYPT
	fi
}



modENCRYPT(){


		      zenity --info --text "Realize os 3 passos em ordem para obter autenticação, integridade e confidencialidade, após realizar os passos clique em sair para salvar as chaves criadas na pasta do projeto"

		     projetonome=$(zenity --title="Nome do projeto" --text "Digite o nome do projeto!" --entry)

mkdir $projetonome

while :;do
               	       opcao1=$(zenity --list --title "Selecione uma das opções abaixo!" --width=650 --height=380 --column id --column Descrição 1 "Etapa 1 - Cria um MAC de um arquivo com uma chave pseudoaleatoria do tamanho selecionado.  " 2 "Etapa 2 - Cria uma chave pseudoaleatoria do tamanho selecionado e cifra um arquivo no formato ecb ou cbc com iv pseudoaleatorio." 3 "Etapa 3 - Gera um par de chaves assimetricas e criptografa usando uma chave publica." 4 " Sair - depois de realizado as etapas clique em sair para salvar todas suas chaves. ")   
        if [ $opcao1 == "4" ]
                then
zenity --info --text " Todas suas chaves foram salvas com sucesso!"
break

		
	fi


	if [ $opcao1 == "1" ]
                then
		#keysize=$(zenity --list --title "Tamanho da chave do MAC pseudoaleatoria" --text "Selecione o tamanho da chave pseudoaleatoria do MAC" --radiolist --column "  " --column "Size" TRUE "128" FALSE "256")

                # aux=$[$keysize/8]
		 key=$(openssl rand -hex 16)
                 echo $key > k.MAC.txt
                 file=$(zenity --title "Selecione o arquivo que será criado o MAC com a chave aleatoria k.mac!" --width=650 --height=380 --file-selection )

openssl dgst -hmac $key -md5 -out x.MAC.txt < $file
		zenity --info --text "Chave aleatoria k.MAC e x.MAC do arquivo selecionado criadas na pasta $projetonome "

        fi


	if [ $opcao1 == "3" ]
                       then


		opmod=$(zenity --list --title "Cifras" --text "Selecione uma opção" --radiolist --column "  " --column "Criar par de chaves ou cifrar com chave publica existente" 1 "Criar" 2 "Cifrar com chave publica existente")

	if [ $opmod == "Criar" ]

		 then
        	
		rsakey=$(zenity --title="Nome da chave" --text "Digite o nome da chave Publica e Privada!" --entry)

openssl genrsa -out $rsakey'.pr'

openssl rsa -in $rsakey'.pr' -outform PEM -pubout -out $rsakey'.pub'
		
		zenity --info --text " As chaves foram criadas! "
	else        
mkdir $projetonome/encryptkeys
       	     
		file=$(zenity --title "Selecione o arquivo que será cifrado com a chave publica!" --width=650 --height=380 --file-selection )
# savedir=$(zenity --file-selection --save)


		keyencrypt=$(zenity --title "Selecione a chave publica!" --width=650 --height=380 --file-selection )

		filenameencrypt=$(zenity --title="Nome do arquivo criptografado" --text "Digite o nome para salvar o novo arquivo criptografado" --entry)
	
#echo "$file a $keyencrypt a $filenameencrypt"

openssl rsautl -in $file -out $projetonome/encryptkeys/$filenameencrypt -inkey $keyencrypt -pubin -encrypt

		zenity --info --text " chave criptografada com nome de $filenameencrypt  salva na pasta $projetonome/encryptkeys"

#iv.ENC.txt x.MAC.txt k.MAC.txt k.ENC.txt
	fi
	fi	       


	 if [ $opcao1 == "2" ]
                       then

		opmod=$(zenity --list --title "Modo de operação" --text "Selecione o modo de operação" --radiolist --column "  " --column "Algorítimo" TRUE "ECB" FALSE "CBC")

	if [ $opmod == "ECB" ]
        then
                modECB
        else
                modCBC
	fi


	fi

mv iv.ENC.txt x.MAC.txt k.MAC.txt k.ENC.txt $projetonome

done 

}


modDECRYPT(){


while :;do
mkdir decryptFiles

		opcao1=$(zenity --list --title "Selecione uma das opções abaixo!" --width=650 --height=380 --column id --column Descrição 1 "Etapa 1 - Descriptografar arquivos com chave RSA privada.  " 2 "Etapa 2 - Descriptografar modos ECB e CBC ." 3 "Etapa 3 - Comparar MAC gerado de um arquivo." 4 " Sair - Sair ")



	 if [ $opcao1 == "1" ]
                 then
 		zenity --info --text "Os arquivos descriptografados vão ser encontrados na pasta decryptFiles "
 		zenity --info --text "Selecione o arquivo que será descriptografado !"
		file=$(zenity --title "Selecione o arquivo que será descriptografado com a chave RSA privada!" --width=650 --height=380 --file-selection )
		zenity --info --text "Selecione a chave RSA privada!"
		keycrypte=$(zenity --title "Selecione a chave RSA privada!" --width=650 --height=380 --file-selection )

		filenameencrypt=$(zenity --title="Nome do arquivo descriptografado" --text "Digite o nome para salvar o novo arquivo descriptografado" --entry)


openssl rsautl -in $file -out decryptFiles/$filenameencrypt -inkey $keycrypte -decrypt

		zenity --info --text "Arquivo descriptografado !"

	fi	
if [ $opcao1 == "2" ]
                 then

mode=$(zenity --list --title "Selecione uma das opções abaixo!" --width=600 --height=380 --column id --column Descrição 1 "ECB" 2 "CBC")


	if [ $mode == "1" ]
                 then
decryptECB

	fi

	if [ $mode == "2" ]
                 then

decryptCBC

	fi
fi	
	if [ $opcao1 == "3" ]
                 then
	zenity --info --text "Selecione o arquivo com o x.mac que deseja comparar"
	file1=$(zenity --title "Selecione o x.MAC.txt arquivo com o mac que deseja comparar" --width=650 --height=380 --file-selection )
zenity --info --text "Selecione o arquivo com a chave k.mac para gerar o x2.MAC do arquivo descriptografado"

 	aux=$(zenity --title "Selecione o arquivo com chave k.mac.txt para gerar o x2.mac do arquivo descriptografado " --width=650 --height=380 --file-selection )
zenity --info --text "Selecione o arquivo do qual sera gerado o MAC e comparado com o primeiro MAC"

	file2=$(zenity --title "Selecione o arquivo do qual sera gerado o MAC!" --width=650 --height=380 --file-selection )
                                key=$(head -1 $aux)
openssl dgst -hmac $key -md5 -out x2.MAC.tmp < $file2
      
	diff $file1 x2.MAC.tmp

	if [ "$?" -eq "0" ];
then zenity --info --text "Parabéns os Mac coincidem!!! "
else zenity --info --text "Os Mac selecionados nao coincidem! "

fi


fi
	if [ $opcao1 == "4" ]
              then
		break
	fi

done
}
testedependencias
EXEC
