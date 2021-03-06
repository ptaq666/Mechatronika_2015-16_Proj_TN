%skrypt do tworzenia bazy danych kod�w b�yskowych
rozmiar_klastra_SD = 512;               %rozmiar klastra danych na karcie SD
fclose('all');                          %zamkniecie wszystkich plikow
IDout = fopen('KODY.txt','w');   %otwarcie pliku do zapisu
IDkom = fopen('komentarz.txt');         %otwarcie pliku komentarza
ID1 = fopen('MAZDA 626 ECU.txt');       %otwarcie pliku z kodami
ID2 = fopen('MAZDA MPV ECU.txt');       %otwarcie pliku z kodami
ID3 = fopen('MAZDA MPV ABS.txt');       %otwarcie pliku z kodami
ID4 = fopen('OPEL ASTRA F ECU.txt');    %otwarcie pliku z kodami
IDs = [ID1 ID2 ID3 ID4];                %tablica z uchwytami plik�w
str = fread(IDkom,2*rozmiar_klastra_SD-1);                %wczytanie komentarza max 1024 znaki
n = numel(str);                         %sprawdzenie d�ugo�ci komentarza i uzupe�nienie do 1024 znaki
if n<(2*rozmiar_klastra_SD-1)
   str =[str; zeros(((2*rozmiar_klastra_SD)-n-1),1,'uint8')];
end
str =[str; '#'];
fwrite(IDout,str);                      %zapis komentarza do pliku

poczatek_adresow = ftell(IDout);        %pobranie miejsca poczatku adresow tablic
ilosc_tablic = size(IDs,2);             %odczyt ilosci tablic

%rezerwacja miejsca
wielkosc_tablicy_adresow = ilosc_tablic*32; 
wielkosc_tablicy_adresow = rozmiar_klastra_SD*ceil(wielkosc_tablicy_adresow/rozmiar_klastra_SD);
str = zeros(wielkosc_tablicy_adresow,1,'uint8');
fwrite(IDout,str);                      %zapisanie zer w miejsce adresow tablic

for tablica=1:ilosc_tablic
   poczatek_tablicy =  ftell(IDout);
   str = fread(IDs(tablica));
   n = numel(str);
   wiekosc_tablicy = rozmiar_klastra_SD*ceil(n/rozmiar_klastra_SD);
   if n<wiekosc_tablicy
        str =[str; zeros(((wiekosc_tablicy)-n),1,'uint8')];
   end
   fwrite(IDout,str);                      %zapis tablicy do pliku
   adres = [uint8(rem(poczatek_tablicy/16777216,256)); rem(poczatek_tablicy/65536,256); rem(poczatek_tablicy/256,256);rem(poczatek_tablicy,256)];
   nazwa_tablicy = [str(3:29); adres;ilosc_tablic];
   fseek(IDout,poczatek_adresow+32*(tablica-1),'bof');
   fwrite(IDout,nazwa_tablicy);                      %zapis nazwy tablicy i jej adresu do pliku
   fseek(IDout,0,'eof');
   
end



fclose('all');  %zamkniecie wszystkich plikow