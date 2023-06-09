clc
clear all
close all
%Autor: ANTONIO JUSTO GONZÁLEZ
%El codigo se ha realizado con comentario ingles/español según el día
% en que hize cada parte. El código tiene muchas partes repetidas que
% se podrían simplificar, aunque en su momento quise independizar cada
% etapa y así hacerlo modular, aunque esto suponga tener mas lineas de
% codigo de las necesarias, por eso el codigo es NOT DRY.  Aun no
% tiene implementadas tecnicas de back tracking o tecnicas que cuando
% se atasque intente probar elecciones aletaroias de las casillas
% restantes buscando ya de una forma no deterministica cual seria la
% siguiente casilla que podriamos rellenar. El codigo lo realize hace
% ya bastante tiempo, unos 5 meses, por lo que puede que presnete
% errores sin corregir. Aunque en el futuro deseo añadirle algunos
% metodos mas que puedan resolver sudokuys mas complejos y que
% presentan ifnormacion mas oculta y que por lo que requiere metodos
% mas arduos. ademas de intentar implementar una interfaz de usuario
% en lugar de hacer uso de excell

tic()
pkg load io
%Escribe tu sudoku en el Excel poniendo CEROS en las casillas que no tengas valor
Sudoku_og = xlsread("sudoku.xlsx");
Sudoku_to_modify = Sudoku_og;
% Step 1 we first identify the posible number for each row for each
% column and for each square, before we star colecting the posibe
% values that each bin could take

%%  ROWS
tic()
[n,m] = size(Sudoku_og);
Matrix_left_rows = zeros(n,m);
M_squares_old = zeros(n,m);

for i = 1:n
  reference_row = [1 2 3 4 5 6 7 8 9];
   for j = 1:m
     if Sudoku_og(i,j) != 0 %leemos el numero que tenemos
       a = Sudoku_og(i,j); %el propio numero que tenemos en el sudokuy nos
       % sirve de indicador
       reference_row(a) = 0; %Elimninamos los propios numero del vector
       % base
     else
       continue
     end
   end
   Matrix_left_rows(i,:) = reference_row; 
end
clear reference_row
toc()
%%  COLUMNS
tic()
Matrix_left_columns = zeros(n,m);

for j = 1:m
  reference_column = [1 2 3 4 5 6 7 8 9];
   for i = 1:n
     if Sudoku_og(i,j) != 0 %leemos el numero que tenemos
       a = Sudoku_og(i,j); %el propio numero que tenemos en el sudokuy nos
       % sirve de indicador
       reference_column(a) = 0; %Elimninamos los propios numero del vector
       % referencia
     else
       continue
     end
   end

   Matrix_left_columns(j,:) = reference_column;

end
clear reference_column
toc()

%% SQUARES
tic()
number_squares = n/3; %Number of 3x3 square
Matrix_left_squares = zeros(n,m); %cada fila es un
% cuadrado los 3 primeras filas son los cuadrado 3x3 horizontales de
% la primera fila, los siguientes lo siguientes pero para la fila i+3,
% y las ultimas tres apra la i+6

iii = 1;
for i = 1:3:(n-2) %Squares 3x3 vertical, rows
  for j = 1:3:(m-2) %Squares 3x3 horizontal, columns
  reference_square = [1 2 3 4 5 6 7 8 9];  
    for ii = i:(i+2) %recorremos las fils del square 3x3
      
      for jj = j:(j+2) %recorremos las columnas del square 3x3
        
        if Sudoku_og(ii,jj) != 0 %leemos el numero que tenemos
         a = Sudoku_og(ii,jj); %el propio numero que tenemos en el sudokuy nos
         % sirve de indicador
         reference_square(a) = 0; %Elimninamos los propios numero del vector
         % referencia
         
       else
         continue
       end
       
      end
    end
    
   Matrix_left_squares(iii,:) = reference_square;
   
   iii = iii + 1; %Nos sirve para escribir en la matriz de cuadrados
  end
end
clear reference_square
toc()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Vector para cada bin de los posibles valores que puede tomar segun el
% valor de numeros disponibles en esa fila, en esa columna, y en esa square
%Vector que nos marca las casillas vacias
tic()

ii = 1;
jump = 0; %variable interna para leer los parametro de la matriz de cuadrados

%Inicializamos nuestras amtrices de numeros
Matrix_1 = zeros(n,m);
Matrix_2 = zeros(n,m);
Matrix_3 = zeros(n,m);
Matrix_4 = zeros(n,m);
Matrix_5 = zeros(n,m);
Matrix_6 = zeros(n,m);
Matrix_7 = zeros(n,m);
Matrix_8 = zeros(n,m);
Matrix_9 = zeros(n,m);

counter_stuck = 1; %This counter will help us break out of the main loop when there is no new changes or placement, meaning that we are stuck
counter_fin = 1; %To get out

for i = 1:n %We run through all the rows in the sudoku
  for j= 1:m %We run throug all the columns in the sudoku
    
    if Sudoku_og(i,j) == 0 %We check if it is an empty bin
%      %Now we check the values that can be placed inside that bin2dec
%      reference_bin = [1 2 3 4 5 6 7 8 9];
      %We pick the right row for the correct 3x3 square we are dealing with
      if j <= 3
        ii = 1 + jump;
        right_square = Matrix_left_squares(ii,:);
      elseif j >3 && j<= 6
        ii = 2 + jump;
        right_square = Matrix_left_squares(ii,:);
      elseif j > 6 && j <=9
        ii = 3 + jump;
        right_square = Matrix_left_squares(ii,:);
      end
      
      for b = 1:9 %B recorre todo los valores de 1 a 9 de los posibles valores que un bin puede tomar
        
        %cuidado como accedemos, las columnas estan guardas en filas, al igual que la amtriz de filas por lo que tenemos que comporbar los valores 1:9 e ir mirando si este valor existe a la vez como posibilidad en las 3 condiciones. En la amtriz de columnas nos movemos hacia abajo conforme nos movemos a la derecha en las columnasd el sudoku, y en la amtriz de las filas nos movemos normal hacia abajo a la vez que nos movemos hacia abajo en el sudoku, por ello podemos utilizar el sikmbolo nde i. Podriamos trasponer la de las colujmnas pero mejor no
        
        if Matrix_left_columns(j,b)!=0 && Matrix_left_rows(i,b) !=0 && right_square(1,b)!=0 %El valor es posible en esa fila, columna y square, por lo que esa casilla almacenamos el valor
          
          a = Matrix_left_columns(j,b); %or Matrix_left_rows(i,b) or right_square(1,b)
          
          %Para almacenar se utilizanm las coodernadas i e j ya que lo estamos gueardando en amtrices igual que los sudokus, y para ello se utilizn las coordendas de cada bin
          if a == 1
            Matrix_1(i,j) = 1;
          elseif a == 2
            Matrix_2(i,j) = 1;
          elseif a == 3
            Matrix_3(i,j) = 1;
          elseif a == 4
            Matrix_4(i,j) = 1;
          elseif a == 5
            Matrix_5(i,j) = 1;  
          elseif a == 6
            Matrix_6(i,j) = 1;  
          elseif a == 7
            Matrix_7(i,j) = 1; 
          elseif a == 8
            Matrix_8(i,j) = 1;  
          elseif a == 9
            Matrix_9(i,j) = 1;
          end
          
        end
     end
     
    end
  end
%  row = [i j reference_bin];
%  Matrix_bins = [Matrix_bins; row];

  %Ya que durante las primeras 3 filas i, el vector de cuadrados son los mismos
  if i == 3 || i == 6
    jump = jump + 3;
  end
  
end
toc()
%We add the value that came already with the sudoku
tic()
for i = 1:n
  for j = 1:m
    if Sudoku_og(i,j) != 0
      
      a = Sudoku_og(i,j);
      
      if a == 1
        Matrix_1(i,j) = 1;
      elseif a == 2
        Matrix_2(i,j) = 1;
      elseif a == 3
        Matrix_3(i,j) = 1;
      elseif a == 4
        Matrix_4(i,j) = 1;
      elseif a == 5
        Matrix_5(i,j) = 1;  
      elseif a == 6
        Matrix_6(i,j) = 1;  
      elseif a == 7
        Matrix_7(i,j) = 1; 
      elseif a == 8
        Matrix_8(i,j) = 1;  
      elseif a == 9
        Matrix_9(i,j) = 1;
      end
      
    end
  end
end

toc()

%% Comprobacion primera antes de hacer comparacions entre valores de filas y de columnas para ver si hay en un square para alguno de los numeros solo una casilla disponible, si no es asÃ­, miramos en Ã±as filas y las columnas, para ver si ese bin, puede tener un valor explsivamente si es el que falta en la fila o en la columna
tic()

zero_row = zeros(1,m);
zero_column = zeros(n,1);
max_loop = 50;
for s = 1:max_loop %while sum(Matrix_left_columns(:))!=0 

%For every posible number
for a = 1:9 %We run through all the number matrix (Matrix_1 ..etc)
  
  if a == 1
    Matrix_X = Matrix_1;
    jump = 0; %Reseteamos variable para el siguiente numero
  elseif a == 2
    Matrix_X = Matrix_2;
    jump = 0;
  elseif a == 3
    Matrix_X = Matrix_3;
    jump = 0;
  elseif a == 4
    Matrix_X = Matrix_4;
    jump = 0;
  elseif a == 5
    Matrix_X = Matrix_5;
    jump = 0; 
  elseif a == 6
    Matrix_X = Matrix_6; 
    jump = 0; 
  elseif a == 7
    Matrix_X = Matrix_7;
    jump = 0;
  elseif a == 8
    Matrix_X = Matrix_8;
    jump = 0;
  elseif a == 9
    Matrix_X = Matrix_9;
    jump = 0;
  end
  
  %For every square 3x3
  %we run through the 9 square for each number a
  for ii = 1:3:(n-2) %Squares 3x3 vertical, rows
    %Ya que durante las primeras 3 filas i, el vector de cuadrados son los mismos, esto es por com tenemos alamcenados los valores de numeros posibles en la matriz de matrix_left_squares
    if ii == 4 || ii == 7
        jump = jump + 3;
    end
    
    for jj = 1:3:(m-2)  %Squares 3x3 horizontal, columns
      square = Matrix_X(ii:(ii+2),jj:(jj+2));
      %comporbamos si para el numero a, se puede hacer placement en este square extraido
      if jj == 1
        fila_square = 1 + jump;
      elseif jj == 4
        fila_square = 2 + jump;
      elseif jj == 7
        fila_square = 3 + jump;
      end
      right_square = Matrix_left_squares(fila_square,:);

      if right_square(a)!=0  && sum(square(:)) == 1 %There is only one place in this square where a value can be imputet, thus we enter the if to make a placement and modify for the a value all the rows and columns, making them zero. AND that number has not being placed already-
        
        %we seach the coordinates of the value to make a placement in the square matrix, knowing that we have a desfase ii,jj
       
       %for every bin 
          for iii = 1:3
            for jjj = 1:3
              if square(iii,jjj) == 1 %Buscamos donde el valor vale 1
                  %Nuestras coordenada de fila y columna una vez teniedo en cuenta el desfase de la submatrix 3x3 que extraimos oara maor comodidad

                  Cordenada_row = ii + iii -1;        
                  Cordenada_column = jj + jjj -1;

                  %we overwrite the colum and the row with zeros and place a 1 in the corresponding coordinate of the Matrix_a
                  Matrix_X(Cordenada_row,:) = zero_row; 
                  Matrix_X(:,Cordenada_column) = zero_column; 
                  %We record a 1 in the corresponding bin
                  Matrix_X(Cordenada_row,Cordenada_column) = 1;
                  
                  %Finally make a placement, in the sudoku
                  Sudoku_to_modify(Cordenada_row,Cordenada_column) = a;
                  disp("Placement by: SQUARES")
                  [a Cordenada_row Cordenada_column]
                  
                  %Ahora nos falta eliminar de todas las otras Matrix_1, Matrix_2 etc para las coodendas i e j en donde hemos puesto un numero esa posibilidad
                  A = ones(n,m);
                  A(Cordenada_row,Cordenada_column) = 0;
                  if a != 1
                    Matrix_1 = Matrix_1.*A;
                  end
                  if a != 2
                    Matrix_2 = Matrix_2.*A;
                  end
                  if a != 3
                    Matrix_3 = Matrix_3.*A;
                  end
                  if a != 4
                    Matrix_4 = Matrix_4.*A;
                  end
                  if a != 5
                    Matrix_5 = Matrix_5.*A;
                  end
                  if a != 6
                    Matrix_6 = Matrix_6.*A; 
                  end
                  if a != 7
                    Matrix_7 = Matrix_7.*A;
                  end
                  if a != 8
                    Matrix_8 = Matrix_8.*A;
                  end
                  if a != 9
                    Matrix_9 = Matrix_9.*A;
                  end 
                  
              endif
              
            endfor
          endfor
          
          %Quitamos el valor, en ese square y en las matrices que alamcenan esos valores de filas y columnas
          right_square(a) = 0;
          %Tenemos que quitar el numero que acabamos de colocar
          Matrix_left_squares(fila_square,:) = right_square;
          Matrix_left_rows(Cordenada_row,a) = 0;
          Matrix_left_columns(Cordenada_column,a) = 0;
        
      elseif right_square(a)!=0  && (sum(square(:)) == 2 || sum(square(:)) == 3) 
        %In the case where two or three posibles bin are line up, and thus share all the same row or the same columns we can not enter for example the if above, but since there all since a common coordinate we can remove from that roww all other options that are in the same row or column, this can only be applied if ALL the potion inside a square 3x3 for a number a, share a common index
        
        if sum(square(:)) == 2
          %En este vector almacenamos las coordenadas de las psoiciones de los valore sunidad para despues ver si tienen todas en comun alguna coordenada          
          Cordenadas_for_2 = zeros(2,2);
          index_for_2 = 1;
          for iii = 1:3
            for jjj = 1:3
              if square(iii,jjj) == 1 %Buscamos donde el valor vale 1
                  %Nuestras coordenada de fila y columna una vez teniedo en cuenta el desfase de la submatrix 3x3 que extraimos oara maor comodidad

                  Cordenada_row = ii + iii -1;        
                  Cordenada_column = jj + jjj -1;
                  
                  Cordenadas_for_2(index_for_2,1) = Cordenada_row;
                  Cordenadas_for_2(index_for_2,2) = Cordenada_column;
                  
                  %Incrementamos el valor del indice para poder alamcenar y que no se sobrescriban                  
                  index_for_2 = index_for_2 +1;
              end
            end
          end
          
          %ahora comprobamos que fila o columna es coincidente
           if Cordenadas_for_2(1,1) == Cordenadas_for_2(2,1) %Misma fila
             Suma_fila = sum(Matrix_X(Cordenadas_for_2(1,1),:));
             if Suma_fila > 2 %We avoid entering when there is only two posible values that are in the same square
               
                %we overwrite the colum and the row with zeros and place a 1 in the corresponding coordinate of the Matrix_a
                %Quitamos todos lÃ±os unos en la fila
                Matrix_X(Cordenadas_for_2(1,1),:) = zero_row; 
                %We record a 1 in the corresponding bin
                %Volvemos a reescribir los uno en las dos posiciones conocidaas
                Matrix_X(Cordenadas_for_2(1,1),Cordenadas_for_2(1,2)) = 1;
                Matrix_X(Cordenadas_for_2(2,1),Cordenadas_for_2(2,2)) = 1;
                
                disp("Half restriction_2 values: ROW")
                a
                Cordenadas_for_2
             end
                              
           elseif Cordenadas_for_2(1,2) == Cordenadas_for_2(2,2) %Misma columna
                
             Suma_columna = sum(Matrix_X(:,Cordenadas_for_2(1,2)));
             if Suma_columna > 2 %We avoid entering when there is only two posible values that are in the same square  
               
                %we overwrite the colum and the row with zeros and place a 1 in the corresponding coordinate of the Matrix_a
                Matrix_X(:,Cordenadas_for_2(1,2)) = zero_column; 
                %We record a 1 in the corresponding bin
                Matrix_X(Cordenadas_for_2(1,1),Cordenadas_for_2(1,2)) = 1;
                Matrix_X(Cordenadas_for_2(2,1),Cordenadas_for_2(2,2)) = 1;                      
                
                disp("Half restriction_2 values: COLUMN")
                a
                Cordenadas_for_2
             end
              
           end
           
        elseif sum(square(:)) == 3
          %En este vector almacenamos las coordenadas de las psoiciones de los valore sunidad para despues ver si tienen todas en comun alguna coordenada
          Cordenadas_for_3 = zeros(3,3);
          index_for_3 = 1;
          for iii = 1:3
            for jjj = 1:3
              if square(iii,jjj) == 1 %Buscamos donde el valor vale 1
                  %Nuestras coordenada de fila y columna una vez teniedo en cuenta el desfase de la submatrix 3x3 que extraimos oara maor comodidad

                  Cordenada_row = ii + iii -1;        
                  Cordenada_column = jj + jjj -1;
                  
                  Cordenadas_for_3(index_for_3,1) = Cordenada_row;
                  Cordenadas_for_3(index_for_3,2) = Cordenada_column;
                  
                  %Incrementamos el valor del indice para poder alamcenar y que no se sobrescriban
                  index_for_3 = index_for_3 +1;
              end
            end
          end         
          
          %ahora comprobamos que fila o columna es coincidente
           if Cordenadas_for_3(1,1) == Cordenadas_for_3(2,1) &&Cordenadas_for_3(1,1) == Cordenadas_for_3(3,1)
             
             Suma_fila = sum(Matrix_X(Cordenadas_for_3(1,1),:));
             if Suma_fila > 3 %We avoid entering when there is only two posible values that are in the same square
               
                %we overwrite the colum and the row with zeros and place a 1 in the corresponding coordinate of the Matrix_a
                
                Matrix_X(Cordenadas_for_3(1,1),:) = zero_row; 
                %We record a 1 in the corresponding bin
                Matrix_X(Cordenadas_for_3(1,1),Cordenadas_for_3(1,2)) = 1;
                Matrix_X(Cordenadas_for_3(2,1),Cordenadas_for_3(2,2)) = 1;
                Matrix_X(Cordenadas_for_3(3,1),Cordenadas_for_3(3,2)) = 1; 

                disp("Half restriction_3: ROW")
                a
                Cordenadas_for_3
%                Matrix_7
             end
              
           elseif Cordenadas_for_3(1,2) == Cordenadas_for_3(2,2) && Cordenadas_for_3(1,2) == Cordenadas_for_3(3,2)
              
             Suma_columna = sum(Matrix_X(:,Cordenadas_for_3(1,2)));
             if Suma_columna> 3 %We avoid entering when there is only two posible values that are in the same square
               
                %we overwrite the colum and the row with zeros and place a 1 in the corresponding coordinate of the Matrix_a
    
                Matrix_X(:,Cordenadas_for_3(1,2)) = zero_column; 
                %We record a 1 in the corresponding bin
                Matrix_X(Cordenadas_for_3(1,1),Cordenadas_for_3(1,2)) = 1;
                Matrix_X(Cordenadas_for_3(2,1),Cordenadas_for_3(2,2)) = 1;             
                Matrix_X(Cordenadas_for_3(3,1),Cordenadas_for_3(3,2)) = 1;   
                
                disp("Half restriction_3: COLUMN")
                a
                Cordenadas_for_3   
             end  
           end
        end
          
        
      endif %Fin if the sum(:)
       
    end %fin square loop columnas j
  
  end %fin squares loop filas i
  clear Suma_columna Suma_fila

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Ahora comprobamos las filas y las columnas las restricciones. 
  %Para ello vemos que en toda la fila o en toda la columna solo haya una posicion en la que podamos poner uno de los numero 1 to 9, para ello miramos en cada fila o colkuman y hacemos la suma si el valor es igual 1 y en la matriz de left opver we still have the number we are looking for number -> a <-  we then can make  a placement but if that is not hte case we move on, when we make a placement we have to eliminate that option for the left over matrices so in fguture loops that is not access anymore
  
  jump = 0; %Inicializamos de nuevo
  for i = 1:n
%    if ismember(i,bypass(1;:) == 1
%      continue
%    end

    if i == 4 || i == 7
        jump = jump + 3;
    end
    
    for j = 1:m
      
      %Cogemos los valors de fila y columna de la matriz_X del numero correspondiente
      row_left = Matrix_X(i,:);
      column_left = Matrix_X(:,j);
      row_left_numbers = Matrix_left_rows(i,:);
      column_left_numbers = Matrix_left_columns(:,j);
      
      if Matrix_X(i,j)==1 && row_left_numbers(a)!=0 && sum(row_left(:))==1 && Sudoku_to_modify(i,j)==0 
          %we overwrite the colum and the row with zeros and place a 1 in the corresponding coordinate of the Matrix_a
          Matrix_X(i,:) = zero_row; 
          Matrix_X(:,j) = zero_column; 
          %We record a 1 in the corresponding bin
          %Tenemos que buscar en toda la fila cual es el valor que vale 1, ya que la primera condicion
          Matrix_X(i,j) = 1;
          
          %Finally make a placement, in the sudoku
          Sudoku_to_modify(i,j) = a;
          disp("Placement by: ROWS")
          [a i j]
          
          %Reescribimos y actualizamos loas matrices de valores restantes
          if j == 1
            fila_square = 1 + jump;
          elseif j == 4
            fila_square = 2 + jump;
          elseif j == 7
            fila_square = 3 + jump;
          end
          
          %Actualizamos las matrices de valores restantes
          Matrix_left_squares(fila_square,a) = 0;
          Matrix_left_rows(i,a) = 0;
          Matrix_left_columns(j,a) = 0;
          
          %Ahora nos falta eliminar de todas las otras Matrix_1, Matrix_2 etc para las coodendas i e j en donde hemos puesto un numero esa posibilidad
          A = ones(n,m);
          A(i,j) = 0;
          
          if a != 1
            Matrix_1 = Matrix_1.*A;
          end
          if a != 2
            Matrix_2 = Matrix_2.*A;
          end
          if a != 3
            Matrix_3 = Matrix_3.*A;
          end
          if a != 4
            Matrix_4 = Matrix_4.*A;
          end
          if a != 5
            Matrix_5 = Matrix_5.*A;
          end
          if a != 6
            Matrix_6 = Matrix_6.*A; 
          end
          if a != 7
            Matrix_7 = Matrix_7.*A;
          end
          if a != 8
            Matrix_8 = Matrix_8.*A;
          end
          if a != 9
            Matrix_9 = Matrix_9.*A;
          end
          
          %we can leave this row is done for the number a, we move to the next row or i value
      end
      
      %Ahora para las columnas

      if Matrix_X(i,j)==1 && column_left_numbers(a)!=0 && sum(column_left(:))==1 && Sudoku_to_modify(i,j)==0 
          %we overwrite the colum and the row with zeros and place a 1 in the corresponding coordinate of the Matrix_a
          Matrix_X(i,:) = zero_row; 
          Matrix_X(:,j) = zero_column; 
          %We record a 1 in the corresponding bin
          Matrix_X(i,j) = 1;
          
          disp("Placement by: COLUMNS")
          [a i j]

          %Finally make a placement, in the sudoku
          Sudoku_to_modify(i,j) = a;
          
          %Reescribimos y actualizamos loas matrices de valores restantes
          if j == 1
            fila_square = 1 + jump;
          elseif j == 4
            fila_square = 2 + jump;
          elseif j == 7
            fila_square = 3 + jump;
          end
          
          %Actualizamos las matrices de valores restantes
          Matrix_left_squares(fila_square,a) = 0;
          Matrix_left_rows(i,a) = 0;
          Matrix_left_columns(j,a) = 0;
 
          %Ahora nos falta eliminar de todas las otras Matrix_1, Matrix_2 etc para las coodendas i e j en donde hemos puesto un numero esa posibilidad
%          A = ones(n,m);
%          A(i,j) = 0;
          
          if a != 1
            Matrix_1(i,j) = 0;%Matrix_1.*A;
          end
          if a != 2
            Matrix_2(i,j) = 0;% = Matrix_2.*A;
          end
          if a != 3
            Matrix_3(i,j) = 0;% = Matrix_3.*A;
          end
          if a != 4
            Matrix_4(i,j) = 0;%v = Matrix_4.*A;
          end
          if a != 5
            Matrix_5(i,j) = 0;% = Matrix_5.*A;
          end
          if a != 6
            Matrix_6(i,j) = 0;% = Matrix_6.*A; 
          end
          if a != 7
            Matrix_7(i,j) = 0;% = Matrix_7.*A;
          end
          if a != 8
            Matrix_8(i,j) = 0;% = Matrix_8.*A;
          end
          if a != 9
            Matrix_9(i,j) = 0;% = Matrix_9.*A;
          end
 
      end   
     
    end
    %Reseteamos la variable jump
    jump = 0;
  end
  
  %Se puede dar el caso de que si tenemos 3 cuadrados alineados, y en dos de ello las opciones estan confinadas en las mismas dos columnas o las dos misma filas, por lo que para el tercer cuadrado podemos implementar la restriccion de que su mismo numero tendrÃ¡que ir a la ultima fila ya que aunque no podemos colocar ningun numero ya que aun no lo sabemos si podemos decir a ciencia cierta de que o uno va en una fila y en el otro cuadrado la otra o al rever por lo que no queda otro que para el tercer cuadrado que esta alineado ya se ahorizontalmente o verticalmente que este vaya en la ultima fila no comun apra ninguna de las otros dos cuadrados

 
  %Primero lo hacemos para los cuadrados alineados horizontalmente
  for i = 1:3:(n-2)
    square1 = Matrix_X(i:(i+2),1:3);
    square2 = Matrix_X(i:(i+2),4:6);
    square3 = Matrix_X(i:(i+2),7:9);
    
    %Tenemos que tener almenos dos valores en dos filas distintas en als tres cuadrdos 3x3, sino nos movemos a la siguiente linea
    if sum(square1(:)) >=2 && sum(square2(:)) >=2 && sum(square3(:)) >=2
      continue
    end

    Suma1 = sum(Matrix_X(i,1:3));
    Suma2 = sum(Matrix_X((i+1),1:3));
    Suma3 = sum(Matrix_X((i+2),1:3));
    
    Suma4 = sum(Matrix_X(i,4:6));
    Suma5 = sum(Matrix_X((i+1),4:6));
    Suma6 = sum(Matrix_X((i+2),4:6));
    
    Suma7 = sum(Matrix_X(i,7:9));
    Suma8 = sum(Matrix_X((i+1),7:9));
    Suma9 = sum(Matrix_X((i+2),7:9));
    
    if Suma1 !=0 && Suma2 !=0 && Suma3 ==0
        if (Suma4 !=0 && Suma5 != 0 && Suma6 == 0) && Suma7!=0 && Suma8 !=0 %The last 2 is to avoid repetition
          A = [0 0 0; 0 0 0; 1 1 1];
          square3 = square3.*A;
          Matrix_X(i:(i+2),7:9) = square3;
          disp("DOUBLE Half restriction_3 square: ROWS 1 and 2")
          a
          i
        elseif (Suma7 !=0 && Suma8 != 0 && Suma9 == 0)&& Suma4!=0 && Suma5 !=0 %The last 2 is to avoid repetition
          A = [0 0 0; 0 0 0; 1 1 1];
          square2 = square2.*A;
          Matrix_X(i:(i+2),4:6) = square2;
          disp("DOUBLE Half restriction_2 square: ROWS 1 and 2")
          a
          i
        end
    elseif Suma1 !=0 && Suma2 ==0 && Suma3 !=0
        if (Suma4 !=0 && Suma5 == 0 && Suma6 != 0)&& Suma7!=0 && Suma9!=0 %The last 2 is to avoid repetition
          A = [0 0 0; 1 1 1;0 0 0];
          square3 = square3.*A;
          Matrix_X(i:(i+2),7:9) = square3;
          disp("DOUBLE Half restriction_3 square: ROWS 1 and 3")
          a
          i          
        elseif (Suma7 !=0 && Suma8 == 0 && Suma9 != 0)&& Suma4!=0 &&Suma6!=0
          A = [0 0 0; 1 1 1;0 0 0];
          square2 = square2.*A;
          Matrix_X(i:(i+2),4:6) = square2;
          disp("DOUBLE Half restriction_2 aquare: ROWS 1 and 3")
          a 
          i
        end
    elseif Suma1 ==0 && Suma2 !=0 && Suma3 !=0
        if (Suma4 ==0 && Suma5 != 0 && Suma6 != 0) && Suma8!=0 &&Suma9!=0
          A = [1 1 1;0 0 0;0 0 0];
          square3 = square3.*A;
          Matrix_X(i:(i+2),7:9) = square3;
          disp("DOUBLE Half restriction_3 square: ROWS 2 and 3")
          a 
          i
        elseif (Suma7 ==0 && Suma8 != 0 && Suma9 != 0) && Suma5!= 0&& Suma6!=0
          A = [1 1 1;0 0 0;0 0 0];
          square2 = square2.*A;
          Matrix_X(i:(i+2),4:6) = square2;
          disp("DOUBLE Half restriction_2 square: ROWS 2 and 3")
          a
          i 
        end      
    end
    
  end
  
  %Ahora lo hacemos para los cuadrados alineados verticalmente
  %We make the transpose to so we can reuse the code abode at the end we undo the transpose again
  
  Matrix_X = Matrix_X';
  for i = 1:3:(n-2)
    square1 = Matrix_X(i:(i+2),1:3);
    square2 = Matrix_X(i:(i+2),4:6);
    square3 = Matrix_X(i:(i+2),7:9);
    
    %Tenemos que tener almenos dos valores en dos filas distintas en als tres cuadrdos 3x3, sino nos movemos a la siguiente linea
    if sum(square1(:)) >=2 && sum(square2(:)) >=2 && sum(square3(:)) >=2
      continue
    end

    Suma1 = sum(Matrix_X(i,1:3));
    Suma2 = sum(Matrix_X((i+1),1:3));
    Suma3 = sum(Matrix_X((i+2),1:3));
    
    Suma4 = sum(Matrix_X(i,4:6));
    Suma5 = sum(Matrix_X((i+1),4:6));
    Suma6 = sum(Matrix_X((i+2),4:6));
    
    Suma7 = sum(Matrix_X(i,7:9));
    Suma8 = sum(Matrix_X((i+1),7:9));
    Suma9 = sum(Matrix_X((i+2),7:9));
    
    if Suma1 !=0 && Suma2 !=0 && Suma3 ==0
        if (Suma4 !=0 && Suma5 != 0 && Suma6 == 0) && Suma7!=0 && Suma8 !=0 %The last 2 is to avoid repetition
          A = [0 0 0; 0 0 0; 1 1 1];
          square3 = square3.*A;
          Matrix_X(i:(i+2),7:9) = square3;
          disp("DOUBLE Half restriction_3 square: COLUMNS 1 and 2")
          a
          i
        elseif (Suma7 !=0 && Suma8 != 0 && Suma9 == 0)&& Suma4!=0 && Suma5 !=0 %The last 2 is to avoid repetition
          A = [0 0 0; 0 0 0; 1 1 1];
          square2 = square2.*A;
          Matrix_X(i:(i+2),4:6) = square2;
          disp("DOUBLE Half restriction_2 aquare: COLUMNS  1 and 2")
          a
          i
          end
    elseif Suma1 !=0 && Suma2 ==0 && Suma3 !=0
        if (Suma4 !=0 && Suma5 == 0 && Suma6 != 0)&& Suma7!=0 && Suma9!=0 %The last 2 is to avoid repetition
          A = [0 0 0; 1 1 1;0 0 0];
          square3 = square3.*A;
          Matrix_X(i:(i+2),7:9) = square3;
          disp("DOUBLE Half restriction_3 aquare: COLUMNS  1 and 3")
          a
          i          
        elseif (Suma7 !=0 && Suma8 == 0 && Suma9 != 0)&& Suma4!=0 &&Suma6!=0
          A = [0 0 0; 1 1 1;0 0 0];
          square2 = square2.*A;
          Matrix_X(i:(i+2),4:6) = square2;
          disp("DOUBLE Half restriction_2 aquare: COLUMNS  1 and 3")
          a 
          i
        end
    elseif Suma1 ==0 && Suma2 !=0 && Suma3 !=0
        if (Suma4 ==0 && Suma5 != 0 && Suma6 != 0) && Suma8!=0 &&Suma9!=0
          A = [1 1 1;0 0 0;0 0 0];
          square3 = square3.*A;
          Matrix_X(i:(i+2),7:9) = square3;
          disp("DOUBLE Half restriction_3 aquare: COLUMNS  2 and 3")
          a
          i 
        elseif (Suma7 ==0 && Suma8 != 0 && Suma9 != 0) && Suma5!= 0&& Suma6!=0
          A = [1 1 1;0 0 0;0 0 0];
          square2 = square2.*A;
          Matrix_X(i:(i+2),4:6) = square2;
          disp("DOUBLE Half restriction_2 aquare: COLUMNS  2 and 3")
          a 
          i
        end      
    end
    
  end
  %Desacemos la traspuesta ya que para ahorrar tiempo y noe scribir lo mismo pero ahora con columnas hemos transpuesto para mirar las columnas que estan verticalmente horizontalmente
  Matrix_X = Matrix_X'; 
 
  
  %Reescribimos las matrices
  if a == 1
    Matrix_1 = Matrix_X;
  elseif a == 2
    Matrix_2 = Matrix_X;
  elseif a == 3
    Matrix_3 = Matrix_X;
  elseif a == 4
    Matrix_4 = Matrix_X;
  elseif a == 5
    Matrix_5 = Matrix_X;
  elseif a == 6
    Matrix_6 = Matrix_X; 
  elseif a == 7
    Matrix_7 = Matrix_X;
  elseif a == 8
    Matrix_8 = Matrix_X;
  elseif a == 9
    Matrix_9 = Matrix_X;
  end  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %CUANDO UNA CASILLA SOLO PUEDE TOMAR UN UNICO VALOR
  %Ahora vamos a comporbar que para cada casilla o bin si se da el casod e que solo esa casilla puede tomar un valor en concreto, para ello tenemos que mira para las coordendas i e j para cada casilla en toda las matrices de numeros Matrix_X
  
  %Creamos una matriz sumandolas todas casilla a casilla si el valor es iguala a la unidad entonces tenemos solo un valor posible para esa casilla y solo tendremos que buscarlos a traves de las otras matrices
  Matrix_total = Matrix_1 + Matrix_2 + Matrix_3 + Matrix_4 + Matrix_5 + Matrix_6 + Matrix_7 + Matrix_8 + Matrix_9;
  
  for i = 1:n
    for j = 1:m
      
      if Matrix_total(i,j) == 1 && Sudoku_to_modify(i,j)==0 %hAY UNA CASILLa que solo puede tomar un valor, y no hemos puesto aun valor en el sudoku es decir la casilla esta vacia
        
        %Primero cogemos de nuevo la Matrix_X correspondiente
        if Matrix_1(i,j)==1
          Matrix_X = Matrix_1;
          numero = 1; %since we cannot use a to refer to the number
        elseif Matrix_2(i,j) == 1
          Matrix_X = Matrix_2;
          numero = 2;
        elseif Matrix_3(i,j) == 1
          Matrix_X = Matrix_3;
          numero = 3;
        elseif Matrix_4(i,j) == 1
          Matrix_X = Matrix_4;
          numero = 4;
        elseif Matrix_5(i,j) == 1
          Matrix_X = Matrix_5;
          numero = 5;
        elseif Matrix_6(i,j) == 1
          Matrix_X = Matrix_6;
          numero = 6;
        elseif Matrix_7(i,j) == 1
          Matrix_X = Matrix_7;
          numero = 7;
        elseif Matrix_8(i,j) == 1
          Matrix_X = Matrix_8;
          numero = 8;
        elseif Matrix_9(i,j) == 1
          Matrix_X = Matrix_9;
          numero = 9;
        end
        %we overwrite the colum and the row with zeros and place a 1 in the corresponding coordinate of the Matrix_a
        Matrix_X(i,:) = zero_row; 
        Matrix_X(:,j) = zero_column; 
        %We record a 1 in the corresponding bin
        Matrix_X(i,j) = 1;
        
        disp("Placement by BIN: ONLY POSIBLE VALUE")
        [i j numero]

        %Finally make a placement, in the sudoku
        Sudoku_to_modify(i,j) = numero;
 
        %Reescribimos las matrices
        if Matrix_1(i,j)==1
          Matrix_1 = Matrix_X;
        elseif Matrix_2(i,j)==1
          Matrix_2 = Matrix_X;
        elseif Matrix_3(i,j)==1
          Matrix_3 = Matrix_X;
        elseif Matrix_4(i,j)==1
          Matrix_4 = Matrix_X;
        elseif Matrix_5(i,j)==1
          Matrix_5 = Matrix_X;
        elseif Matrix_6(i,j)==1
          Matrix_6 = Matrix_X; 
        elseif Matrix_7(i,j)==1
          Matrix_7 = Matrix_X;
        elseif Matrix_8(i,j)==1
          Matrix_8 = Matrix_X;
        elseif Matrix_9(i,j)==1
          Matrix_9 = Matrix_X;
        end 
        
      endif
    end
  end
  clear numero
    
end %for a = 1:9 we run through the numbers
  textt = ["++++++++++++++++++++++Contador loop, iteraccion ", num2str(s),"/",num2str(max_loop), ".++++++++++++++++++++++"];
  disp(textt)

  Flag_2 = 0;
  if sum(Sudoku_to_modify(:)) == 45*9
    disp("Sudoku solved!!!")
    counter_fin = counter_fin +1;
    if counter_fin == 4
      break
    end
  elseif sum(Sudoku_to_modify(:)) < 45*9 && s == max_loop
    disp("Sudoku NOT solved!!!")
  elseif M_squares_old == Matrix_left_squares 
    disp("Sudoku is STUCK, HELP!!!")
    counter_stuck = counter_stuck + 1;
    Flag_2 = 1
    if counter_stuck == 9
      break
    end
    
  end
  
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Hidden && Naked subset pairs
%Flag_2 =0;
if Flag_2 == 1 
%We only do this when we are stuck, to save computation time

%We can instead, cheak for each number that it is messing for each square, cheks its pattern with all the other numbers that are still missing in that square, but for that number we are comparing we need to find the number of bins with a one, or posibble bins where we can place this number, and try to find a match if we find one, then we have to see if the numbers of bins in the comparing number is 2 we can stop the check for that number, since we know that there cannot by another pattern for other separete number apart from this two that can make a match, if the number of bins of the number we are comparing is bigger than 2 we continue with all the remaning numbers in that square, and see at the ened, if the number of bins for the comparing number is equal to the number of matches that we have found if it is so, then we can move to clean those bins for any number that could share those bins from the remaining number for the square and that it is not one of the matching numbers. the good thing about this is that it deals with naked subsets or with hidden subsets indiferently, otherwise we would also need to program latter on a way to deal with hidden subsets, since if we are to use the matrixX total, wewould find that there
% are bins where there can only be 2 values, but since there are other numbr there the number for that bin in the matirxX total is
% bigger and obscure the subset pair that would allow us to clean that square and remove posibilities

%We program naked Subset, when we have twosquares line up, where they are the one that have two value there and there alone, thus we know that those two bins have to take one value and the other the other one, thus we can remvoe all the other posible values that those bins could take, removing options for those bin and allowing, in some case to simplify options 


%If number of bins with the same numbers == number of numbers "a" shared common between those bins, where  those number do not exist outside these bins, thus we can eliminate any other number a part for the group of shared number a, since this number of bin will take the share list of number and no others since this numbers do not exist outside these group of bins
 
%Utilizamos Matrix_total total, to find bins with two options only in a square, we are working with naked only pair, there is also hided subsbt pairs where there are other values, but in that case we will have to make a search different

  
jump = 0;
Matrix_already_cleaned_bins = zeros(n,m); 
for ii = 1:3:(n-2) %Squares 3x3 vertical, rows
    %Ya que durante las primeras 3 filas i, el vector de cuadrados son los mismos, esto es por com tenemos alamcenados los valores de numeros posibles en la matriz de matrix_left_squares
    if ii == 4 || ii == 7
        jump = jump + 3;
    end
    
  for jj = 1:3:(m-2)  %Squares 3x3 horizontal, columns

      %comporbamos si para el numero a, se puede hacer una colocación en este square extraido
        if jj == 1
          fila_square = 1 + jump;
        elseif jj == 4
          fila_square = 2 + jump;
        elseif jj == 7
          fila_square = 3 + jump;
        end
      %Pick the remaining numbers for the riogh square
      right_square_left = Matrix_left_squares(fila_square,:);

      if sum(right_square_left)!=0   %We check that there are still numbers
      % left to place in this square, and that the number pick 
        
        for a = 1:(size(right_square_left,2)-1) %We run through the right square_left to check the first number left to, we omit the last value since we have nothing to compare with we
          % compare with the number left ahead of the one we have just taken, this is because the last has already being compared , we compare with the numbers forward  
          if right_square_left(a)!=0 %We take the number that is still remain to check its pattern
            
            if a == 1
              Matrix_X = Matrix_1;
            elseif a == 2
              Matrix_X = Matrix_2;
            elseif a == 3
              Matrix_X = Matrix_3;
            elseif a == 4
              Matrix_X = Matrix_4;
            elseif a == 5
              Matrix_X = Matrix_5; 
            elseif a == 6
              Matrix_X = Matrix_6; 
            elseif a == 7
              Matrix_X = Matrix_7;
            elseif a == 8
              Matrix_X = Matrix_8;
%            elseif a == 9 %WE OMIT THIS VALUE
%              Matrix_X = Matrix_9;
            end
            
            %We pick, for the choosen number, the right square and compare with all the other, we are going to comapre the first square with all the other square fro all the other number matrices and then move to the next square and o the same
            square_pattern_to_check = Matrix_X(ii:(ii+2),jj:(jj+2));
            
            if sum(square_pattern_to_check) == 1
              continue %we can move to the next number that it is left for this square, since this number has already being placed in the square
            end
            
            Matrix_matches = zeros(1,n);
            %This value is for the pattern we are checking
            Matrix_matches(1,a) = 1;
            for k = 1:(size(right_square_left,2)) %Here it is the second amtrix that we are going to do the comaprison so we run to the very end 
              if right_square_left(k)!=0 && k != a %We take the number that is still remain to check its pattern
              %WE PICK THE OTHER MATRIX to compare
                if k == 1
                  Matrix_X_2 = Matrix_1;
                elseif k == 2
                  Matrix_X_2 = Matrix_2;
                elseif k == 3
                  Matrix_X_2 = Matrix_3;
                elseif k == 4
                  Matrix_X_2 = Matrix_4;
                elseif k == 5
                  Matrix_X_2 = Matrix_5; 
                elseif k == 6
                  Matrix_X_2 = Matrix_6; 
                elseif k == 7
                  Matrix_X_2 = Matrix_7;
                elseif k == 8
                  Matrix_X_2 = Matrix_8;
                elseif k == 9 
                  Matrix_X_2 = Matrix_9;
                end
                
                %We take the right square
                
                square_pattern_to_compare_with = Matrix_X_2(ii:(ii+2),jj:(jj+2));
                
                  if square_pattern_to_check == square_pattern_to_compare_with
                    %if this requierement is met then,m we have a match
                     %We save in this matrix the matches, menaing for the number a = 2, that we have extracted from Matrix_X the righ square, we comapre with k =7, from where we got Matrix_X_2 and wee have extracted the same square, and compare the pattern of 1 and zeros fromt his two square since there is a match we store for latter remove for this square and for the corresponding bins where we have the 1, all other values from any other numbers that are not a =2 and k =7, in the scase of having 3 bins and 3 numbers we would have a tripplet
                     Matrix_matches(1,k) = 1;
                  endif
                
              endif
                
            endfor %for where we run through all remaining numbers that are left to be placed in this choosen square 3x3
            
            %If we have had a match, then we move to find the bins where we have numbers and clean all the rest
            %Before moving to the next number a that it is left to be place for this square we see if we had a match and remove athe 1 for those bins
            if sum(Matrix_matches)>1 %We have a match, and one is for the pattern                    
              kk = 1;
              Coordenadas_iii = [];
              Coordenadas_jjj = [];
              %We run through all the bion in my 3x3 square
              for iii = 1:3
                for jjj = 1:3
                  if square_pattern_to_check(iii,jjj) != 0
                    %we save the global coordinates of the bins where we have a 1
                    Coordenadas_iii(1,kk) = ii + iii -1;
                    Coordenadas_jjj(1,kk) = jj + jjj -1;
                    kk = kk + 1;
                  endif
                end
              end
              clear iii jjj kk
              
              %Now using the matrching matrix we run through all the bins where we had a match
              %WE HAVE TO IMPLEMENT THAT THE NUMBER OF BINS IS EQUAL TO THE NYUMBER OF MATCHES WE ARE MISSING THAT
              
%              a
%              right_square_left
%              Matrix_matches 
%              num_bins = size(Cordenadas_iii,2)
%              [Cordenadas_iii;Cordenadas_jjj]
%              square_pattern_to_check
%              Matrix_7
%              Matrix_total = Matrix_1 + Matrix_2 + Matrix_3 + Matrix_4 + Matrix_5 + Matrix_6 + Matrix_7 + Matrix_8 + Matrix_9
              
              %El numero de bins es igual al numero de matches de patrones
              if size(Coordenadas_iii,2) == sum(Matrix_matches)

                for f = 1:size(Coordenadas_iii,2)
                  
                  %cogemos las coordenadas
                  Ci = Coordenadas_iii(1,f);
                  Cj = Coordenadas_jjj(1,f);

                  %Reescribimos las matrices
                  %we check that for taht bin we have a 1, or is a bin where we could save a number and we also check that we havent had a match for this number in the pattern thus we remove this number for this bin
                  %We check if we havent already cleaned this bin
                  if Matrix_already_cleaned_bins(Ci,Cj) == 0
                  %We store that we have already cleaned this bins
                  Matrix_already_cleaned_bins(Ci,Cj) = 1;
                  
                    if Matrix_1(Ci,Cj)== 1 && Matrix_matches(1,1) == 0 
                      Matrix_1(Ci,Cj) = 0;
                      disp("HIDEN SETS/NAKED SETS: SQUARES Hidden subset 1")
                    end
                    if Matrix_2(Ci,Cj)==1 && Matrix_matches(1,2) == 0 
                      Matrix_2(Ci,Cj) = 0;
                      disp("HIDEN SETS/NAKED SETS: SQUARES Hidden subset 2")
                    end
                    if Matrix_3(Ci,Cj)==1 && Matrix_matches(1,3) == 0 
                      Matrix_3(Ci,Cj) = 0;
                      disp("HIDEN SETS/NAKED SETS: SQUARES Hidden subset 3")
                    end
                    if Matrix_4(Ci,Cj)==1 && Matrix_matches(1,4) == 0 
                      Matrix_4(Ci,Cj) = 0;
                      disp("HIDEN SETS/NAKED SETS: SQUARES Hidden subset 4")
                    end  
                    if Matrix_5(Ci,Cj)==1 && Matrix_matches(1,5) == 0 
                      Matrix_5(Ci,Cj) = 0;
                      disp("HIDEN SETS/NAKED SETS: SQUARES Hidden subset 5")
                    end
                    if Matrix_6(Ci,Cj)==1 && Matrix_matches(1,6) == 0 
                      Matrix_6(Ci,Cj) = 0; 
                      disp("HIDEN SETS/NAKED SETS: SQUARES Hidden subset 6")
                    end
                    if Matrix_7(Ci,Cj)==1 && Matrix_matches(1,7) == 0 
                      Matrix_7(Ci,Cj) = 0;
                      disp("HIDEN SETS/NAKED SETS: SQUARES Hidden subset 7")
                    end
                    if Matrix_8(Ci,Cj)==1 && Matrix_matches(1,8) == 0 
                      Matrix_8(Ci,Cj) = 0;
                      disp("HIDEN SETS/NAKED SETS: SQUARES Hidden subset 8")
                    end
                    if Matrix_9(Ci,Cj)==1 && Matrix_matches(1,9) == 0 
                      Matrix_9(Ci,Cj) = 0;
                      disp("HIDEN SETS/NAKED SETS: SQUARES Hidden subset 9")
                    end 
                 end 
                
                endfor%we run through all the options of the bins stored of my pattern          
              endif %Comprobamos que el numero de bins es igual al numero de matches
              
              clear Ci Cj f Coordenadas_iii Coordenadas_jjj
            endif %End for the if where we check if we have had a match         
                
          endif %We take the number that is still remain to check its pattern 
        
        endfor %end for the numbers 1:9-1 that we want to compere with the rest
      endif%We check that there are still number left to place in this square, and that the number pick 
  end
end

%Now we are going to find hiddeln subsets or naked one but by cheking rows and columns

%ROWS

%Matrix_already_cleaned_bins 
for ii = 1:n % rows

    %Pick the remaining numbers for the riogh square
    right_row_left = Matrix_left_rows(ii,:);

    if sum(right_row_left)!=0   %We check that there are still number left to place in this row, and that the number pick 
      
      for a = 1:(size(right_row_left,2)-1) %We run through the right square_left to check the first number left to, we omit the last value since we have nothing to compare with w e comapre with the number left ahead of the one we have just taken, this is because the last has already being compared, we compare with the numbers forward  
        if right_row_left(a)!=0 %We take the number that is still remain to check its pattern
          
          if a == 1
            Matrix_X = Matrix_1;
          elseif a == 2
            Matrix_X = Matrix_2;
          elseif a == 3
            Matrix_X = Matrix_3;
          elseif a == 4
            Matrix_X = Matrix_4;
          elseif a == 5
            Matrix_X = Matrix_5; 
          elseif a == 6
            Matrix_X = Matrix_6; 
          elseif a == 7
            Matrix_X = Matrix_7;
          elseif a == 8
            Matrix_X = Matrix_8;
%            elseif a == 9 %WE OMIT THIS VALUE
%              Matrix_X = Matrix_9;
          end
          
          %We pick, for the choosen number, the right square and compare with all the other, we are going to comapre the first square with all the other square fro all the other number matrices and then move to the next square and o the same
          row_pattern_to_check = Matrix_X(ii,:);
          
          if sum(row_pattern_to_check) == 1
            continue %we can move to the next number that it is left for this row, since this number has already being placed in the row
          end
          
          Matrix_matches = zeros(1,n);
          %This value is for the pattern we are checking
          Matrix_matches(1,a) = 1;
          for k = 1:(size(right_row_left,2)) %Here it is the second amtrix that we are going to do the comaprison so we run to the very end 
            if right_row_left(k)!=0 && k != a %We take the number that is still remain to check its pattern
            %WE PICK THE OTHER MATRIX to compare
              if k == 1
                Matrix_X_2 = Matrix_1;
              elseif k == 2
                Matrix_X_2 = Matrix_2;
              elseif k == 3
                Matrix_X_2 = Matrix_3;
              elseif k == 4
                Matrix_X_2 = Matrix_4;
              elseif k == 5
                Matrix_X_2 = Matrix_5; 
              elseif k == 6
                Matrix_X_2 = Matrix_6; 
              elseif k == 7
                Matrix_X_2 = Matrix_7;
              elseif k == 8
                Matrix_X_2 = Matrix_8;
              elseif k == 9 
                Matrix_X_2 = Matrix_9;
              end
              
              %We take the right square
              
              row_pattern_to_compare_with = Matrix_X_2(ii,:);
              
                if row_pattern_to_check == row_pattern_to_compare_with
                  %if this requierement is met then,m we have a match
                   %We save in this matrix the matches, menaing for the number a = 2, that we have extracted from Matrix_X the righ square, we comapre with k =7, from where we got Matrix_X_2 and wee have extracted the same square, and compare the pattern of 1 and zeros fromt his two square since there is a match we store for latter remove for this square and for the corresponding bins where we have the 1, all other values from any other numbers that are not a =2 and k =7, in the scase of having 3 bins and 3 numbers we would have a tripplet
                   Matrix_matches(1,k) = 1;
                endif
              
            endif
              
          endfor %for where we run through all remaining numbers that are left to be placed in this choosen square 3x3
          
          %If we have had a match, then we move to find the bins where we have numbers and clean all the rest
          %Before moving to the next number a that it is left to be place for this square we see if we had a match and remove athe 1 for those bins
          if sum(Matrix_matches)>1 %We have a match, and one is for the pattern                    
            kk = 1;
            Coordenadas_iii = [];
            Coordenadas_jjj = [];
            %We run through all the bion in my 3x3 square
             
            for jjj = 1:size(row_pattern_to_check,2)
              if row_pattern_to_check(1,jjj) != 0
                %we save the global coordinates of the bins where we have a 1
                Coordenadas_iii(1,kk) = ii;
                Coordenadas_jjj(1,kk) = jjj;
                kk = kk + 1;
              endif
            end
            
            clear jjj kk
            
            %Now using the matrching matrix we run through all the bins where we had a match
            %WE HAVE TO IMPLEMENT THAT THE NUMBER OF BINS IS EQUAL TO THE NYUMBER OF MATCHES WE ARE MISSING THAT
            
%              a
%              right_square_left
%              Matrix_matches 
%              num_bins = size(Coordenadas_iii,2)
%              [Coordenadas_iii;Coordenadas_jjj]
%              square_pattern_to_check
%              Matrix_7
%              Matrix_total = Matrix_1 + Matrix_2 + Matrix_3 + Matrix_4 + Matrix_5 + Matrix_6 + Matrix_7 + Matrix_8 + Matrix_9
            
            %El numero de bins es igual al numero de matches de patrones
            if size(Coordenadas_iii,2) == sum(Matrix_matches)
              %Recorremos todas las coordenadas encontradas
              for f = 1:size(Coordenadas_iii,2)
                
                %cogemos las coordenadas
                Ci = Coordenadas_iii(1,f);
                Cj = Coordenadas_jjj(1,f);

                %Reescribimos las matrices
                %we check that for taht bin we have a 1, or is a bin where we could save a number and we also check that we havent had a match for this number in the pattern thus we remove this number for this bin
                %We check if we havent already cleaned this bin
                if Matrix_already_cleaned_bins(Ci,Cj) == 0
                %We store that we have already cleaned this bins
                Matrix_already_cleaned_bins(Ci,Cj) = 1;
                
                  if Matrix_1(Ci,Cj)== 1 && Matrix_matches(1,1) == 0 
                    Matrix_1(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: ROWS Hidden subset 1")
                  end
                  if Matrix_2(Ci,Cj)==1 && Matrix_matches(1,2) == 0 
                    Matrix_2(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: ROWS Hidden subset 2")
                  end
                  if Matrix_3(Ci,Cj)==1 && Matrix_matches(1,3) == 0 
                    Matrix_3(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: ROWS Hidden subset 3")
                  end
                  if Matrix_4(Ci,Cj)==1 && Matrix_matches(1,4) == 0 
                    Matrix_4(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: ROWS Hidden subset 4")
                  end  
                  if Matrix_5(Ci,Cj)==1 && Matrix_matches(1,5) == 0 
                    Matrix_5(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: ROWS Hidden subset 5")
                  end
                  if Matrix_6(Ci,Cj)==1 && Matrix_matches(1,6) == 0 
                    Matrix_6(Ci,Cj) = 0; 
                    disp("HIDEN SETS/NAKED SETS: ROWS Hidden subset 6")
                  end
                  if Matrix_7(Ci,Cj)==1 && Matrix_matches(1,7) == 0 
                    Matrix_7(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: ROWS Hidden subset 7")
                  end
                  if Matrix_8(Ci,Cj)==1 && Matrix_matches(1,8) == 0 
                    Matrix_8(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: ROWS Hidden subset 8")
                  end
                  if Matrix_9(Ci,Cj)==1 && Matrix_matches(1,9) == 0 
                    Matrix_9(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: ROWS Hidden subset 9")
                  end 
               end 
              
              endfor%we run through all the options of the bins stored of my pattern          
            endif %Comprobamos que el numero de bins es igual al numero de matches
            
            clear Ci Cj f Coordenadas_iii Coordenadas_jjj
          endif %End for the if where we check if we have had a match         
          
        
        endif %We take the number that is still remain to check its pattern 
      
      endfor %end for the numbers 1:9-1 that we want to compere with the rest
    endif%We check that there are still number left to place in this square, and that the number pick 
end %end of rows

%COLUMNS

%wE ARE GOING TO REUSE CODE, FOR THAT FOR THE COLUMNS WE MAE THE TRANSPOSE AND TEAT THEM AS ROWS AND AT THE END WE REVERSE
Matrix_already_cleaned_bins = Matrix_already_cleaned_bins';
Matrix_1 = Matrix_1';
Matrix_2 = Matrix_2';
Matrix_3 = Matrix_3';
Matrix_4 = Matrix_4';
Matrix_5 = Matrix_5';
Matrix_6 = Matrix_6';
Matrix_7 = Matrix_7';
Matrix_8 = Matrix_8';
Matrix_9 = Matrix_9';

for ii = 1:n % rows

    %Pick the remaining numbers for the riogh square
    right_row_left = Matrix_left_rows(ii,:);

    if sum(right_row_left)!=0   %We check that there are still number left to place in this row, and that the number pick 
      
      for a = 1:(size(right_row_left,2)-1) %We run through the right square_left to check the first number left to, we omit the last value since we have nothing to compare with w e comapre with the number left ahead of the one we have just taken, this is because the last has already being compared, we compare with the numbers forward  
        if right_row_left(a)!=0 %We take the number that is still remain to check its pattern
          
          if a == 1
            Matrix_X = Matrix_1;
          elseif a == 2
            Matrix_X = Matrix_2;
          elseif a == 3
            Matrix_X = Matrix_3;
          elseif a == 4
            Matrix_X = Matrix_4;
          elseif a == 5
            Matrix_X = Matrix_5; 
          elseif a == 6
            Matrix_X = Matrix_6; 
          elseif a == 7
            Matrix_X = Matrix_7;
          elseif a == 8
            Matrix_X = Matrix_8;
%            elseif a == 9 %WE OMIT THIS VALUE
%              Matrix_X = Matrix_9;
          end
          
          %We pick, for the choosen number, the right square and compare with all the other, we are going to comapre the first square with all the other square fro all the other number matrices and then move to the next square and o the same
          row_pattern_to_check = Matrix_X(ii,:);
          
          if sum(row_pattern_to_check) == 1
            continue %we can move to the next number that it is left for this row, since this number has already being placed in the row
          end
          
          Matrix_matches = zeros(1,n);
          %This value is for the pattern we are checking
          Matrix_matches(1,a) = 1;
          for k = 1:(size(right_row_left,2)) %Here it is the second amtrix that we are going to do the comaprison so we run to the very end 
            if right_row_left(k)!=0 && k != a %We take the number that is still remain to check its pattern
            %WE PICK THE OTHER MATRIX to compare
              if k == 1
                Matrix_X_2 = Matrix_1;
              elseif k == 2
                Matrix_X_2 = Matrix_2;
              elseif k == 3
                Matrix_X_2 = Matrix_3;
              elseif k == 4
                Matrix_X_2 = Matrix_4;
              elseif k == 5
                Matrix_X_2 = Matrix_5; 
              elseif k == 6
                Matrix_X_2 = Matrix_6; 
              elseif k == 7
                Matrix_X_2 = Matrix_7;
              elseif k == 8
                Matrix_X_2 = Matrix_8;
              elseif k == 9 
                Matrix_X_2 = Matrix_9;
              end
              
              %We take the right square
              
              row_pattern_to_compare_with = Matrix_X_2(ii,:);
              
                if row_pattern_to_check == row_pattern_to_compare_with
                  %if this requierement is met then,m we have a match
                   %We save in this matrix the matches, menaing for the number a = 2, that we have extracted from Matrix_X the righ square, we comapre with k =7, from where we got Matrix_X_2 and wee have extracted the same square, and compare the pattern of 1 and zeros fromt his two square since there is a match we store for latter remove for this square and for the corresponding bins where we have the 1, all other values from any other numbers that are not a =2 and k =7, in the scase of having 3 bins and 3 numbers we would have a tripplet
                   Matrix_matches(1,k) = 1;
                endif
              
            endif
              
          endfor %for where we run through all remaining numbers that are left to be placed in this choosen square 3x3
          
          %If we have had a match, then we move to find the bins where we have numbers and clean all the rest
          %Before moving to the next number a that it is left to be place for this square we see if we had a match and remove athe 1 for those bins
          if sum(Matrix_matches)>1 %We have a match, and one is for the pattern                    
            kk = 1;
            Coordenadas_iii = [];
            Coordenadas_jjj = [];
            %We run through all the bion in my 3x3 square
             
            for jjj = 1:size(row_pattern_to_check,2)
              if row_pattern_to_check(1,jjj) != 0
                %we save the global coordinates of the bins where we have a 1
                Coordenadas_iii(1,kk) = ii;
                Coordenadas_jjj(1,kk) = jjj;
                kk = kk + 1;
              endif
            end
            
            clear jjj kk
            
            %Now using the matrching matrix we run through all the bins where we had a match
            %WE HAVE TO IMPLEMENT THAT THE NUMBER OF BINS IS EQUAL TO THE NYUMBER OF MATCHES WE ARE MISSING THAT
            
%              a
%              right_square_left
%              Matrix_matches 
%              num_bins = size(Coordenadas_iii,2)
%              [Coordenadas_iii;Coordenadas_jjj]
%              square_pattern_to_check
%              Matrix_7
%              Matrix_total = Matrix_1 + Matrix_2 + Matrix_3 + Matrix_4 + Matrix_5 + Matrix_6 + Matrix_7 + Matrix_8 + Matrix_9
            
            %El numero de bins es igual al numero de matches de patrones
            if size(Coordenadas_iii,2) == sum(Matrix_matches)
              %Recorremos todas las coordenadas encontradas
              for f = 1:size(Coordenadas_iii,2)
                
                %cogemos las coordenadas
                Ci = Coordenadas_iii(1,f);
                Cj = Coordenadas_jjj(1,f);

                %Reescribimos las matrices
                %we check that for taht bin we have a 1, or is a bin where we could save a number and we also check that we havent had a match for this number in the pattern thus we remove this number for this bin
                %We check if we havent already cleaned this bin
                if Matrix_already_cleaned_bins(Ci,Cj) == 0
                %We store that we have already cleaned this bins
                Matrix_already_cleaned_bins(Ci,Cj) = 1;
                
                  if Matrix_1(Ci,Cj)== 1 && Matrix_matches(1,1) == 0 
                    Matrix_1(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: COLUMNS Hidden subset 1")
                  end
                  if Matrix_2(Ci,Cj)==1 && Matrix_matches(1,2) == 0 
                    Matrix_2(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: COLUMNS Hidden subset 2")
                  end
                  if Matrix_3(Ci,Cj)==1 && Matrix_matches(1,3) == 0 
                    Matrix_3(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: COLUMNS Hidden subset 3")
                  end
                  if Matrix_4(Ci,Cj)==1 && Matrix_matches(1,4) == 0 
                    Matrix_4(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: COLUMNS Hidden subset 4")
                  end  
                  if Matrix_5(Ci,Cj)==1 && Matrix_matches(1,5) == 0 
                    Matrix_5(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: COLUMNS Hidden subset 5")
                  end
                  if Matrix_6(Ci,Cj)==1 && Matrix_matches(1,6) == 0 
                    Matrix_6(Ci,Cj) = 0; 
                    disp("HIDEN SETS/NAKED SETS: COLUMNS Hidden subset 6")
                  end
                  if Matrix_7(Ci,Cj)==1 && Matrix_matches(1,7) == 0 
                    Matrix_7(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: COLUMNS Hidden subset 7")
                  end
                  if Matrix_8(Ci,Cj)==1 && Matrix_matches(1,8) == 0 
                    Matrix_8(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: COLUMNS Hidden subset 8")
                  end
                  if Matrix_9(Ci,Cj)==1 && Matrix_matches(1,9) == 0 
                    Matrix_9(Ci,Cj) = 0;
                    disp("HIDEN SETS/NAKED SETS: COLUMNS Hidden subset 9")
                  end 
               end 
              
              endfor%we run through all the options of the bins stored of my pattern          
            endif %Comprobamos que el numero de bins es igual al numero de matches
            
            clear Ci Cj f Coordenadas_iii Coordenadas_jjj
          endif %End for the if where we check if we have had a match         
          
        
        endif %We take the number that is still remain to check its pattern 
      
      endfor %end for the numbers 1:9-1 that we want to compere with the rest
    endif%We check that there are still number left to place in this square, and that the number pick 
end %end of columns

Matrix_already_cleaned_bins = Matrix_already_cleaned_bins';
Matrix_1 = Matrix_1';
Matrix_2 = Matrix_2';
Matrix_3 = Matrix_3';
Matrix_4 = Matrix_4';
Matrix_5 = Matrix_5';
Matrix_6 = Matrix_6';
Matrix_7 = Matrix_7';
Matrix_8 = Matrix_8';
Matrix_9 = Matrix_9';

%we set the flag latter on more down
%Flag_2 = 0; %We set the flag back to zero
%Matrix_total = Matrix_1 + Matrix_2 + Matrix_3 + Matrix_4 + Matrix_5 + Matrix_6 + Matrix_7 + Matrix_8 + Matrix_9;

endif %End of flag_2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%X-WING 
%WE now are going to implement Xwing and Sword fish, by taking a matrix for a number, seeking a row where the sum is 2, and doinf this for all rows, now we pick the first row that is equal to 2, ignoring the last and before the last one, in other word rows 9 and 8 since this methos will allow us to eliminate values from the columns that connect the positions of the number in the two rows. this does not llow us to make placements but to clear up avaiblable options for each bins, instead of cheeking every row, we could just first fins which rows have 2 options and only check on those rows avoiding the others

%ROWS
for a = 1:9 %Para todos los numero 1 to 9
  
    if a == 1
      Matrix_X = Matrix_1;
    elseif a == 2
      Matrix_X = Matrix_2;
    elseif a == 3
      Matrix_X = Matrix_3;
    elseif a == 4
      Matrix_X = Matrix_4;
    elseif a == 5
      Matrix_X = Matrix_5; 
    elseif a == 6
      Matrix_X = Matrix_6; 
    elseif a == 7
      Matrix_X = Matrix_7;
    elseif a == 8
      Matrix_X = Matrix_8;
    elseif a == 9 
      Matrix_X = Matrix_9;
    end
    
    %Now we find the rows where we have only 2 matches to form the SQUARE of xwing
    %con estos dos vectores podremos elegir una 
    Sum_rows = zeros(1,n);
    Sum_columns = zeros(1,n);
    for index = 1:n
      sumaro= sum(Matrix_X(index,:));
      sumacol = sum(Matrix_X(:,index));
      %Xwing requiere que en las filas solo se tenga 2 casillas para un numero candidato
      if sumaro == 2
        Sum_rows(1,index) = 1;
      end
      %Xwing requiere tener para las columnas 2 o mas candidatos, en donde de tenerse eel patorn xwing podremos proceder a eliminar las casillas extras para este numero en estas dos columnas que cierra el loop del cuadro
      if sumacol >= 2
        Sum_columns(1,index) = 1;
      end
    endfor
    clear index sumacol sumaro
    %In te case we only have one row with 2 bins for this candidate, we can stops, and if we have only 1 column with 2 candidates we can stoip topo since we cannot close the square
    if sum(Sum_rows) <= 1 || sum(Sum_columns) <= 1
      continue
    end
    
    %We find the coordinates taking the first row where we have no more thant 2 bins, we need to pick from rows 1 to 7, skipping  9 as the first row for the square since picking 9 wont allow us to close the square

    for i = 1:(n-1) %Recorremos todas las filas, ignorando la ultima ya que no podemos formar un cuadrado con esta
        Coordenada_iii = [];
        Coordenada_jjj = [];
        k = 1;
        if Sum_rows(1,i) == 1 %esta fila tiene unicamente 2 valores
          for j = 1:m %recorremos todas las columnas para encontrarlo
            if Matrix_X(i,j) == 1 %Es una casilla para el numero 1 donde podemos poner un valor
              Coordenada_iii(1,k) = i;
              Coordenada_jjj(1,k) = j;
              k = k + 1;
            endif
          end
        else
          continue %Nos movemos a la siguiente fila y volvemos a comprobar si esta es una de las filas en las que unicamente tenemos 2 bins en toda la fila para el numero a
        endif
      
        %Ya hemos encontrado para la fila i, las dos coordendas de los puntos bin donde podemos poner un valor
        %Con este if, pasamos a la siguieite fila donde tengamos 2 valores, ya que con esta comprobacion hemos visto que no podremos cerrar el cuadrado
        if (sum(Matrix_X(:,Coordenada_jjj(1,1))) == 1) || (sum(Matrix_X(:,Coordenada_jjj(1,2))) == 1)  
          continue  %next row, we do not have a way to close the square for this columns    
        end
      
        %We find the next rows, from the current one, and find its cordinates
   
        for ii = (i+1):(n-1) %recorremos el resto de las filas
          Coordenada_iii_2 = [];
          Coordenada_jjj_2 = [];
          k = 1;  
          if Sum_rows(1,ii) == 1 %esta fila tiene unicamente 2 valores
              for jj = 1:m
                  if Matrix_X(ii,jj) == 1 %Es una casilla para el numero 1 donde podemos poner un valor
                    Coordenada_iii_2(1,k) = ii;
                    Coordenada_jjj_2(1,k) = jj;
                    k = k + 1;
                  endif
              end
          else
            continue %we move on to the next row while we seek for the bottom of the square
          endif
      
          %Si las coordenadas de loas columnas del primer y segundos puntos de mi cuadro son iguales entonces tenemos un loop cerrado
          if Coordenada_jjj(1,1) == Coordenada_jjj_2(1,1) &&  Coordenada_jjj(1,2) == Coordenada_jjj_2(1,2)
              %We clean the first column
              b = Coordenada_jjj(1,1);
              if sum(Matrix_X(:,b)) > 2 %we have more value in this column than the two cornes of the square
                zero_column = zeros(m,1);
                Matrix_X(:,b) = zero_column;
                aa = Coordenada_iii(1,1);
                bb = Coordenada_jjj(1,1);
                Matrix_X(aa,bb) = 1;
                aa = Coordenada_iii_2(1,1);
                bb = Coordenada_jjj_2(1,1);
                Matrix_X(aa,bb) = 1; 
                disp("Clearing bins by XWING: ROW 1")  
                a
                aa       
              end
              %We clena the second columns
              b = Coordenada_jjj(1,2);
              if sum(Matrix_X(:,b)) > 2 %we have more value in this column than the two cornes of the square
                zero_column = zeros(m,1);
                Matrix_X(:,b) = zero_column;
                aa = Coordenada_iii(1,2);
                bb = Coordenada_jjj(1,2);
                Matrix_X(aa,bb) = 1;
                aa = Coordenada_iii_2(1,2);
                bb = Coordenada_jjj_2(1,2);
                Matrix_X(aa,bb) = 1; 
                disp("Clearing bins by XWING: ROW 2")
                a 
                aa
              end
              clear aa bb b 
          else
              continue    
          endif
        
        endfor %for loop seek the second row       
      
    endfor %recorremos todas las filas en las que tenemos 2 valores
     
    %Reescribimos las matrices
    if a == 1
      Matrix_1 = Matrix_X;
    elseif a == 2
      Matrix_2 = Matrix_X;
    elseif a == 3
      Matrix_3 = Matrix_X;
    elseif a == 4
      Matrix_4 = Matrix_X;
    elseif a == 5
      Matrix_5 = Matrix_X;
    elseif a == 6
      Matrix_6 = Matrix_X; 
    elseif a == 7
      Matrix_7 = Matrix_X;
    elseif a == 8
      Matrix_8 = Matrix_X;
    elseif a == 9
      Matrix_9 = Matrix_X;
    end
  
end %for para todos los numeros 1:9

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%cOLUMNS xWING
for a = 1:9 %Para todos los numero 1 to 9
  
    if a == 1
      Matrix_X = Matrix_1';
    elseif a == 2
      Matrix_X = Matrix_2';
    elseif a == 3
      Matrix_X = Matrix_3';
    elseif a == 4
      Matrix_X = Matrix_4';
    elseif a == 5
      Matrix_X = Matrix_5'; 
    elseif a == 6
      Matrix_X = Matrix_6'; 
    elseif a == 7
      Matrix_X = Matrix_7';
    elseif a == 8
      Matrix_X = Matrix_8';
    elseif a == 9 
      Matrix_X = Matrix_9';
    end
    
    %Now we find the rows where we have only 2 matches to form the SQUARE of xwing
    %con estos dos vectores podremos elegir una 
    Sum_rows = zeros(1,n);
    Sum_columns = zeros(1,n);
    for index = 1:n
      sumaro= sum(Matrix_X(index,:));
      sumacol = sum(Matrix_X(:,index));
      %Xwing requiere que en las filas solo se tenga 2 casillas para un numero candidato
      if sumaro == 2
        Sum_rows(1,index) = 1;
      end
      %Xwing requiere tener para las columnas 2 o mas candidatos, en donde de tenerse eel patorn xwing podremos proceder a eliminar las casillas extras para este numero en estas dos columnas que cierra el loop del cuadro
      if sumacol >= 2
        Sum_columns(1,index) = 1;
      end
    endfor
    clear index sumacol sumaro
    %In te case we only have one row with 2 bins for this candidate, we can stops, and if we have only 1 column with 2 candidates we can stoip topo since we cannot close the square
    if sum(Sum_rows) <= 1 || sum(Sum_columns) <= 1
      continue
    end
    
    %We find the coordinates taking the first row where we have no more thant 2 bins, we need to pick from rows 1 to 7, skipping  9 as the first row for the square since picking 9 wont allow us to close the square

    for i = 1:(n-1) %Recorremos todas las filas, ignorando la ultima ya que no podemos formar un cuadrado con esta
        Coordenada_iii = [];
        Coordenada_jjj = [];
        k = 1;
        if Sum_rows(1,i) == 1 %esta fila tiene unicamente 2 valores
          for j = 1:m %recorremos todas las columnas para encontrarlo
            if Matrix_X(i,j) == 1 %Es una casilla para el numero 1 donde podemos poner un valor
              Coordenada_iii(1,k) = i;
              Coordenada_jjj(1,k) = j;
              k = k + 1;
            endif
          end
        else
          continue %Nos movemos a la siguiente fila y volvemos a comprobar si esta es una de las filas en las que unicamente tenemos 2 bins en toda la fila para el numero a
        endif
      
        %Ya hemos encontrado para la fila i, las dos coordendas de los puntos bin donde podemos poner un valor
        %Con este if, pasamos a la siguieite fila donde tengamos 2 valores, ya que con esta comprobacion hemos visto que no podremos cerrar el cuadrado
        if (sum(Matrix_X(:,Coordenada_jjj(1,1))) == 1) || (sum(Matrix_X(:,Coordenada_jjj(1,2))) == 1)  
          continue  %next row, we do not have a way to close the square for this columns    
        end
      
        %We find the next rows, from the current one, and find its cordinates
   
        for ii = (i+1):(n-1) %recorremos el resto de las filas
          Coordenada_iii_2 = [];
          Coordenada_jjj_2 = [];
          k = 1;  
          if Sum_rows(1,ii) == 1 %esta fila tiene unicamente 2 valores
              for jj = 1:m
                  if Matrix_X(ii,jj) == 1 %Es una casilla para el numero 1 donde podemos poner un valor
                    Coordenada_iii_2(1,k) = ii;
                    Coordenada_jjj_2(1,k) = jj;
                    k = k + 1;
                  endif
              end
          else
            continue %we move on to the next row while we seek for the bottom of the square
          endif
      
          %Si las coordenadas de loas columnas del primer y segundos puntos de mi cuadro son iguales entonces tenemos un loop cerrado
%          Matrix_X
%          Coordenada_iii
%          Coordenada_jjj
%          Coordenada_iii_2
%          Coordenada_jjj_2
          if Coordenada_jjj(1,1) == Coordenada_jjj_2(1,1) &&  Coordenada_jjj(1,2) == Coordenada_jjj_2(1,2)
          
              %We clean the first column
              b = Coordenada_jjj(1,1);
              if sum(Matrix_X(:,b)) > 2 %we have more value in this column than the two cornes of the square
                zero_column = zeros(m,1);
                Matrix_X(:,b) = zero_column;
                aa = Coordenada_iii(1,1);
                bb = Coordenada_jjj(1,1);
                Matrix_X(aa,bb) = 1;
                aa = Coordenada_iii_2(1,1);
                bb = Coordenada_jjj_2(1,1);
                Matrix_X(aa,bb) = 1; 
                disp("Clearing bins by XWING: COLUMN 1")
                a 
                bb     
              end
              %We clena the second columns
              b = Coordenada_jjj(1,2);
              if sum(Matrix_X(:,b)) > 2 %we have more value in this column than the two cornes of the square
                zero_column = zeros(m,1);
                Matrix_X(:,b) = zero_column;
                aa = Coordenada_iii(1,2);
                bb = Coordenada_jjj(1,2);
                Matrix_X(aa,bb) = 1;
                aa = Coordenada_iii_2(1,2);
                bb = Coordenada_jjj_2(1,2);
                Matrix_X(aa,bb) = 1; 
                disp("Clearing bins by XWING: COLUMN 2")
                a 
                bb
              end
              clear aa bb b 
          else
              continue    
          endif
        
        endfor %for loop seek the second row       
      
    endfor %recorremos todas las filas en las que tenemos 2 valores
     
    %Reescribimos las matrices
    if a == 1
      Matrix_1 = Matrix_X';
    elseif a == 2
      Matrix_2 = Matrix_X';
    elseif a == 3
      Matrix_3 = Matrix_X';
    elseif a == 4
      Matrix_4 = Matrix_X';
    elseif a == 5
      Matrix_5 = Matrix_X';
    elseif a == 6
      Matrix_6 = Matrix_X'; 
    elseif a == 7
      Matrix_7 = Matrix_X';
    elseif a == 8
      Matrix_8 = Matrix_X';
    elseif a == 9
      Matrix_9 = Matrix_X';
    end
  
end %for para todos los numeros 1:9

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%YWing
if Flag_2 == 1
Matrix_total_normal = Matrix_1 + Matrix_2 + Matrix_3 + Matrix_4 + Matrix_5 + Matrix_6 + Matrix_7 + Matrix_8 + Matrix_9;

for i = 1:n
  for j = 1:m
    if Matrix_total_normal(i,j) == 2
      Matrix_total_normal(i,j) = 1;
    else 
      Matrix_total_normal(i,j) = 0;
    end
  end
end

%con estos dos vectores podremos saber si esta fila o columna tiene al menos 2 casillas con 2 opciones o numeros candidatos para esa casilla
Sum_rows = zeros(1,n);
Sum_columns = zeros(1,n);
for index = 1:n
  sumaro= sum(Matrix_total_normal(index,:));
  sumacol = sum(Matrix_total_normal(:,index));

  if sumaro >= 2
    Sum_rows(1,index) = 1;
  end

  if sumacol >= 2
    Sum_columns(1,index) = 1;
  end
endfor
clear index sumacol sumaro


Sum_squares = zeros(n,m);
for i = 1:3:(n-2) %Squares 3x3 vertical, rows
    %Ya que durante las primeras 3 filas i, el vector de cuadrados son los mismos, esto es por com tenemos alamcenados los valores de numeros posibles en la matriz de matrix_left_squares

  for j = 1:3:(m-2)  %Squares 3x3 horizontal, columns
      %comporbamos si para el numero a, se puede hacer placement en este square extraido

      %Pick the remaining numbers for the riogh square
      right_square_normal = Matrix_total_normal(i:(i+2),j:(j+2));
      if sum(right_square_normal(:)) >=2 %tenemos al menos 2 casillas donde podemos poner solo 2 numeros
        for ii = i:(i+2)
          for jj = j:(j+2)
             Sum_squares(ii,jj) =  1;
          end
        end
      end
  end
end
  

%for i = 1:n
%  for j = 1:m
%    if Matrix_total_normal(i,j) == 0 %Esta casilla no tien 2 valores, por lo que es zero
%      continue
%    end
%
%    if Sum_rows(1,i) == 1 && Sum_col(1,j) == 1 || Sum_squares(i,j) == 0 && Sum_rows(1,i) == 1 || Sum_squares(i,j) == 0 && Sum_col(1,j) == 1 %No tenemos suficientes casillas como para conectarlas necesitamos al menos 3
%      continue
%    end
%    
%    %We find the number value for i,j, que tenemos en esta casilla
%    Primera_casilla = [];
%    if Matrix_1(i,j) == 1
%      Primera_casilla(1,end+1) = 1;
%    end
%    if Matrix_2(i,j) == 1
%      Primera_casilla(1,end+1) = 1;
%    end
%    if Matrix_3(i,j) == 1
%      Primera_casilla(1,end+1) = 1;
%    end
%    if Matrix_4(i,j) == 1
%      Primera_casilla(1,end+1) = 1;
%    end
%    if Matrix_5(i,j) == 1
%      Primera_casilla(1,end+1) = 1;
%    end
%    if Matrix_6(i,j) == 1
%      Primera_casilla(1,end+1) = 1;
%    end
%    if Matrix_7(i,j) == 1
%      Primera_casilla(1,end+1) = 1;
%    end
%    if Matrix_8(i,j) == 1
%      Primera_casilla(1,end+1) = 1;
%    end
%    if Matrix_9(i,j) == 1
%      Primera_casilla(1,end+1) = 1;
%    end    
%    
%    Flag_nobininsquare = 0; %to continue to next bin if we do not have match in the other bin that there maybe inside the same square than our first bin
%    if Sum_squares(i,j) == 1 %Buscamos la segunda casilla en el mismo cuadrado que nuestra casilla
%      %Elegimos la casilla correcta
%      if i <= 3 
%        if j <= 3
%          ii = 1;
%          jj = 1;
%        elseif j >= 4 && j <= 6
%          ii = 1;
%          jj = 4;
%        else
%          ii = 1;
%          jj = 7;
%        end
%      elseif i >= 4 && i <= 6
%        if j <= 3
%          ii = 4;
%          jj = 1;
%        elseif j >= 4 && j <= 6
%          ii = 4;
%          jj = 4;
%        else
%          ii = 4;
%          jj = 7;
%        end        
%      else
%        if j <= 3
%          ii = 7;
%          jj = 1;
%        elseif j >= 4 && j <= 6
%          ii = 7;
%          jj = 4;
%        else
%          ii = 7;
%          jj = 7;
%        end
%      end
%      %Buscamos la segunda casilla en este cuadrado
%      for iii = ii:(ii+2)
%        for jjj = jj:(jj+2)
%          Cord_i = ii + iii -1;
%          Cord_j = jj + jjj -1;
%          if Cord_i == i && Cord_i == j
%            continue %we have found the first bin, we need to find the other one, we move to the next column
%          end
%          
%          if Matrix_total_normal(Cord_i,Cord_j) == 1 %we found the other bin
%              Segunda_casilla = [];
%              if Matrix_1(i,j) == 1
%                Segunda_casilla(1,end+1) = 1;
%              end
%              if Matrix_2(i,j) == 1
%                Segunda_casilla(1,end+1) = 1;
%              end
%              if Matrix_3(i,j) == 1
%                Segunda_casilla(1,end+1) = 1;
%              end
%              if Matrix_4(i,j) == 1
%                Segunda_casilla(1,end+1) = 1;
%              end
%              if Matrix_5(i,j) == 1
%                Segunda_casilla(1,end+1) = 1;
%              end
%              if Matrix_6(i,j) == 1
%                Segunda_casilla(1,end+1) = 1;
%              end
%              if Matrix_7(i,j) == 1
%                Segunda_casilla(1,end+1) = 1;
%              end
%              if Matrix_8(i,j) == 1
%                Segunda_casilla(1,end+1) = 1;
%              end
%              if Matrix_9(i,j) == 1
%                Segunda_casilla(1,end+1) = 1;
%              end 
%              Tercera_casilla = [];
%              if Primera_casilla(1,1) == Segunda_casilla(1,1) %We check if the first number is the same between them
%                %Las dos valores sobrantes de las dos primeras casillas me determinan el tercero, el de link tiene que se igual que el valor no comun entre estas dos casillas, es decir el segundo, y su segundo valor tiene que ser el valor extra de esta segunda casilla
%                Tercera_casilla(1,1) = Primera_casilla(1,2);
%                Tercera_casilla(1,1) = Segunda_casilla(1,2);
%                Flag_nobininsquare = 1; %we rise the flag since we found a match
%              elseif Primera_casilla(1,2) == Segunda_casilla(1,2) %We check the second number if this is a match
%                Tercera_casilla(1,1) = Primera_casilla(1,1);
%                Tercera_casilla(1,1) = Segunda_casilla(1,1);
%                Flag_nobininsquare = 1; %we rise the flag since we found a match
%              end
%            
%          endif
%        endfor
%      endfor
%    endif %if sum_square
%    
%    %We have in this row a potencial match when we have 2 bins that have.
%    %This will be the tercer point to check if Flag_nobininsquare == 1;
%    %since we found a match inside the square of the number i,j from where
%    % %we started
%    if sum(Matrix_total_normal(i,(j+1):end) >= 1 %we seek the the next bins with two
%      for jj = (j+1):m
%            
%            Candidato = [];
%            if Matrix_1(i,jj) == 1
%              Candidato(1,end+1) = 1;
%            end
%            if Matrix_2(i,jj) == 1
%              Candidato(1,end+1) = 1;
%            end
%            if Matrix_3(i,jj) == 1
%              Candidato(1,end+1) = 1;
%            end
%            if Matrix_4(i,jj) == 1
%              Candidato(1,end+1) = 1;
%            end
%            if Matrix_5(i,jj) == 1
%              Candidato(1,end+1) = 1;
%            end
%            if Matrix_6(i,jj) == 1
%              Candidato(1,end+1) = 1;
%            end
%            if Matrix_7(i,jj) == 1
%              Candidato(1,end+1) = 1;
%            end
%            if Matrix_8(i,jj) == 1
%              Candidato(1,end+1) = 1;
%            end
%            if Matrix_9(i,jj) == 1
%              Candidato(1,end+1) = 1;
%            end 
%            
%      end
%      if sum(Tercera_casilla) != 0 %The square does nt have a candidate thus we did not enter the if above and thus tercera casilla is empty, if we entered thus the tercer casilla is not empty
%        if Candidato == Tercera_casilla %the candidate fits the premise requiered thus we can proceed to clean
%          
%        end
%      else %We did not fins a candisdate isnide the square thus this is our third candidate
%        Segunda_casilla = Candidato;
%      end
%      
%    endif
%    
%    
%  endfor
%endfor



Flag_2 = 0;
end %end of Flag_2




M_squares_old = Matrix_left_squares; %To check if we have not made any change in the whole 

%If we are still stuck we could then try and pick a value and see which solves the matrix
  
  
end %For the loop of trials
toc()

changes = Sudoku_to_modify - Sudoku_og;
%Write down of the keypoints
xlswrite("Sudoku_solution.xlsx",Sudoku_to_modify);
if sum(Sudoku_to_modify(:)) == 45*9
  disp("Sudoku solved!!!")
elseif sum(Sudoku_to_modify(:)) < 45*9 && s == max_loop
  disp("Sudoku NOT solved,Increase size of main loop!!!")
elseif sum(Sudoku_to_modify(:)) < 45*9 && M_squares_old ==Matrix_left_squares 
  disp("Sudoku is STUCK, FIN DEL CODIGO!!!")
  Matrix_total = Matrix_1 + Matrix_2 + Matrix_3 + Matrix_4 + Matrix_5 + Matrix_6 + Matrix_7 + Matrix_8 + Matrix_9
  Sudoku_to_modify
end
  

clear a i j ii jj number_squares final iii jump b Sum_rows Sum_columns Coordenada_iii Coordenada_jjj Coordenada_iii_2 Coordenada_jjj_2
disp("Code ran in:")
toc()

clear counter_fin k number_squares right_row_left right_square_left row_pattern_to_check row_pattern_to_compare_with square_pattern_to_check square_pattern_to_compare_with Matrix_X Matrix_X_2 Matrix_matches

clear Coordenada_row A Cordenadas_for_2 Cordenadas_for_3 Suma1 Suma2 Suma3 Suma4 Suma5 Suma6 Suma7 Suma8 Suma9 a ans b counter_stuck i ii iii index_for_2 index_for_3 j jj jjj jump s textt square square1 square2 square3 zero_column zero_row column_left_numbers column_left fila_square row_left row_left_numbers right_square Cordenada_column Cordenada_row
