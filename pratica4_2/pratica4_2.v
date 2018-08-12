module pratica4_2(SW, LEDR, HEX0, HEX1, HEX2);
  input [17:0]SW;
  output [17:0]LEDR;
  output [6:0]HEX0, HEX1, HEX2;
  wire [2:0]saida0, saida1, saida2;

  assign LEDR = SW;

  //'b01001001000
  projeto Projetar(SW[17], SW[8:0], saida0, saida1,saida2);

  display7Segmentos Exibe0(saida0, HEX0);
  display7Segmentos Exibe1(saida1, HEX1);
  display7Segmentos Exibe2(saida2, HEX2);
endmodule

module display7Segmentos(Entrada, SaidaDisplay); //visual output
	input [2:0]Entrada;
	output reg [0:6]SaidaDisplay;

	always begin
		case(Entrada)
			0:SaidaDisplay = 7'b1000000; //0
			1:SaidaDisplay = 7'b1111001; //1
			2:SaidaDisplay = 7'b0100100; //2
			3:SaidaDisplay = 7'b0110000; //3
			4:SaidaDisplay = 7'b0011001; //4
			5:SaidaDisplay = 7'b0010010; //5
			6:SaidaDisplay = 7'b0000010; //6
			7:SaidaDisplay = 7'b1111000; //7
			default:SaidaDisplay = 7'b0000000;//F
		endcase
	end
endmodule

module projeto
#(parameter memTAM = 6,parameter cacheTAM = 1)
(clock, entrada, saida0, saida1,saida2);

  input clock;
  input [9:0]entrada;
  output [2:0]saida0, saida1, saida2;
  integer i;

  reg [2:0]signal;      //fala
  reg [2:0]signal2;     //escuta
  reg [2:0]stateDest;
  reg [2:0]stateOri;
  reg [1:0]processador;
  reg [8:0]cacheP1;
  reg [8:0]cacheP2;
  reg [8:0]cacheP3;
  reg [3:0]memoria;
  reg [3:0]data;
  reg achei;
  reg inst;

  assign saida0 = stateOri;
  assign saida1 = stateDest;
  assign saida2 = data[0:2];
  // chacheP1 [8:7] = state
  // cacheP2 [6:4]  = tag
  // cacheP3 [3:0]  = value

  // entrada [9:8]  = processador
  // entrada [7]    = inst
  // entrada [6:4]  = tag
  // entrada [3:0]  = value

  always @ (posedge clock) begin
	 inst = entrada[7];
	 processador = entrada[8:9];
   signal = 0;
   achei = 0;
   if(inst == 1)begin
    // se for write, pega o dado passado
	  data = (entrada[0:3]);
	 end

    //-----------1 PASSO-PROCURAR PELO BLOCO-----------//
    case (inst)
      /* R E A D */
      0:begin //read
          case (processador)//qual processador solicitou
            1:begin
                for(i = 0; i < cacheTAM ; i=i+1)begin
                  // checa a tag
                  if(cacheP1[6:4] == entrada[6:4])begin //READ HIT
                    achei = 1;
			              data = cacheP1[3:0]; // salva o dado
                    stateOri = cacheP1[8:7];
                    // chama a maquina de estados que fala para atualizar
                    // o estado da cache
                    snoop (clock, 3, stateOri, stateDest, signal);
                    // atualiza o estado da cache
                    cacheP2[8:7] = stateDest;
                  end
                end
              end
            2:begin
                for(i = 0; i < cacheTAM ; i=i+1)begin
                  // checa a tag
                  if(cacheP2[6:4] == entrada[6:4])begin //READ HIT
                    achei = 1;
  						      data = cacheP2[3:0];
  						      stateOri = cacheP2[8:7];
                    // chama a maquina de estados que fala para atualizar
                    // o estado da cache
                    snoop (clock, 3, stateOri, stateDest, signal);
                    // atualiza o estado da cache
                    cacheP2[8:7] = stateDest;
                  end
                end
              end
            3:begin
                for(i = 0; i < cacheTAM ; i=i+1)begin
                  // checa a tag
                  if(cacheP3[6:4] == entrada[6:4])begin //READ HIT
                    achei = 1;
  						      data = cacheP3[3:0];
  						      stateOri = cacheP3[8:7];
                    // chama a maquina de estados que fala para atualizar
                    // o estado da cache
                    snoop (clock, 3, stateOri, stateDest, signal);
                    // atualiza o estado da cache
                    cacheP3[8:7] = stateDest;
                  end
                end
              end
          endcase //termina a busca por preferencia

          if(achei == 0 && processador != 1) //procura no 1
          // checa a tag
          // checa o estado, só entra se estive no estado Modificado
          for(i = 0; i < cacheTAM ; i=i+1)begin
            if((cacheP1[6:4] == entrada[6:4]) && (cacheP1[8:7] == 3'b010))begin //read miss|satisfeito pela cache
              achei = 1;
              // pega o dado da cache
      				data = cacheP1[3:0];
      				stateOri = cacheP1[8:7];
              // chama a maquina de estado para atualizar o estado da cache
              snoop (clock, 3'b001, stateOri, stateDest, signal);
              cacheP1[8:7] = stateDest;
            end
          end

          if(achei == 0 && processador != 2) //?rocura no 2
          for(i = 0; i < cacheTAM ; i=i+1)begin
            if((cacheP2[6:4] == entrada[6:4]) && (cacheP2[8:7] == 3'b010))begin //read miss|satisfeito pela cache
              achei = 1;
      				data = cacheP2[3:0];
      				stateOri = cacheP2[8:7];
              snoop (clock, 3'b001, stateOri, stateDest, signal);
              cacheP2[8:7] = stateDest;
            end
          end

          if(achei == 0 && processador != 3) //procura no 3
          for(i = 0; i < cacheTAM ; i=i+1)begin
            // checa a tag
            // checa o estado, só entra se estive no estado Modificado
            if((cacheP3[6:4] == entrada[6:4]) && (cacheP3[8:7] == 3'b010))begin //read miss|satisfeito pela cache
              achei = 1;
              // pega o dado da cache
      				data = cacheP3[3:0];
      				stateOri = cacheP0[8:7];
              // chama a maquina de estado para atualizar o estado da cache
              snoop (clock, 3'b001, stateOri, stateDest, signal);
              cacheP3[8:7] = stateDest;
            end
          end

          if(achei == 0)begin //nao encontrou em lugar algum, satisfaz pela MEM
            case(processador)
              1:begin
                  cacheP1[8:7] = 3'b000;                // estado shared
                  cacheP1[6:4] = entrada[6:4];          // tag
                  cacheP1[3:0] = memoria[entrada[6:4]]; // dado da memória
  					      data = memoria[entrada[6:4]];         // atualiza o dado'
                end
              2:begin
                  cacheP2[8:7] = 3'b000;                // estado shared
                  cacheP2[6:4] = entrada[6:4];          // tag
                  cacheP2[3:0] = memoria[entrada[6:4]]; // dado da memória
		              data = memoria[entrada[6:4]];         // atualiza o dado
                end
              3:begin
                  cacheP3[8:7] = 3'b000;                // estado shared
                  cacheP3[6:4] = entrada[6:4];          // tag
                  cacheP3[3:0] = memoria[entrada[6:4]]; // dado da memória
	                data = memoria[entrada[6:4]];         // atualiza o dado
                end
            endcase
          end
        end //fim read

      /* W R I T E */
      1:begin //write
          case (processador)//qual processador solicitou
            1:begin
                for(i = 0; i < cacheTAM ; i=i+1)begin
                  // confere a tag
                  if(cacheP1[6:4] == entrada[6:4])begin //write hit
                    achei = 1;
  			            stateOri = cacheP1[8:7];
                    // chama a maquina de estado para atualizar o estado da cache
                    snoop (clock, 3'b100, stateOri, stateDest, signal);
                    cacheP1[8:7] = stateDest;
                    // atualiza o dado da cache
  		              cacheP2[3:0] = entrada[3:0];
                  end
                end
              end
            2:begin
                for(i = 0; i < cacheTAM ; i=i+1)begin
                  // confere a tag
                  if(cacheP2[6:4] == entrada[6:4])begin
                    achei = 1;
  			            stateOri = cacheP2[8:7];
                    // chama a maquina de estado para atualizar o estado da cache
                    snoop (clock, 3'b100, stateOri, stateDest, signal);
                    cacheP2[8:7] = stateDest;
                    // atualiza o dado da cache
  			            cacheP2[3:0] = entrada[3:0];
                  end
                end
              end
            3:begin
                for(i = 0; i < cacheTAM ; i=i+1)begin
                  // confere a tag
                  if(cacheP3[6:4] == entrada[6:4])begin
                    achei = 1;
  			            stateOri = cacheP1[8:7];
                    // chama a maquina de estado para atualizar o estado da cache
                    snoop (clock, 3'b100, stateOri, stateDest, signal);
                    cacheP3[8:7] = stateDest;
                    // atualiza o dado da cache
  			            cacheP3[3:0] = entrada[3:0];
                  end
                end
              end
          endcase //termina a busca por preferencia

          if(achei == 0)begin //write miss
    				case(processador)
    					1:begin
      					  stateOri = cacheP1[8:7];
                  // chama a maquina de estado para atualizar o estado da cache
      					  snoop (clock, 3'b010, stateOri, stateDest, signal);
                  // atualiza o dado da cache
      					  cacheP1[8:7] = stateDest;
    					  end
    					2:begin
    				      stateOri = cacheP2[8:7];
                  // chama a maquina de estado para atualizar o estado da cache
      					  snoop (clock, 3'b010, stateOri, stateDest, signal);
                  // atualiza o dado da cache
      					  cacheP2[8:7] = stateDest;
    					  end
    					3:begin
    				      stateOri = cacheP3[8:7];
                  // chama a maquina de estado para atualizar o estado da cache
                  snoop (clock, 3'b010, stateOri, stateDest, signal);
                  // atualiza o dado da cache
                  cacheP3[8:7] = stateDest;
    					  end
				    endcase
          end
        end //fim write
    endcase //fim 1 passo

    //******* 2 PASSO-Tomar atitudes em relação a outros processadores *******//
    case(processador)
      1:begin
        for(i = 0; i < cacheTAM ; i=i+1)begin
          if(cacheP1[6:4] == entrada[6:4])begin
      			snp (clock, signal, stateOri, stateDest, signal2);
      			cacheP1[8:7] = stateDest;
      			if(signal2 == 1)begin
      				memoria[cacheP1[6:4]] = cacheP1[3:0];
            end // if
          end // if
        end // for
      end // case
      2:begin
        for(i = 0; i < cacheTAM ; i=i+1)begin
          if(cacheP2[6:4] == entrada[6:4])begin
      			snp (clock, signal, stateOri, stateDest, signal2);
      			cacheP2[8:7] = stateDest;
      			if(signal2 == 1)begin
      				memoria[cacheP2[6:4]]=cacheP2[3:0];
            end // if
          end // if
        end // for
      end // case
      3:begin
        for(i = 0; i < cacheTAM ; i=i+1)begin
          if(cacheP3[6:4] == entrada[6:4])begin
      			snp (clock, signal, stateOri, stateDest, signal2);
      			cacheP3[8:7] = stateDest;
      			if(signal2 == 1)begin
      				memoria[cacheP3[6:4]]=cacheP3[3:0];
      			end // if
          end // if
        end // for
      end // case
    endcase
  end //fim always

  initial begin
    //-----------Inicia a memoria e as cache-----------//
    for(i = 0; i < memTAM ; i=i+1)begin
      // cada posicao da memória recebe o dado correspondente
      // ao indice da memória
      memoria = i;
    end //for
    for(i = 0; i < cacheTAM ; i=i+1)begin
      // DATA - cada dado da cache recebe o valor
      // correspondente ao indice da cache
      cacheP1[3:0] = i;
      cacheP2[3:0] = i;
      cacheP3[3:0] = i;
      // TAG - cada tag da cache recebe o valor
      // correspondente ao indice da cache
      cacheP1[6:4] = i;
      cacheP2[6:4] = i;
      cacheP3[6:4] = i;
      // STATE - inicia o estado de todas as caches
      // como SHARED
      cacheP1[8:7] = 3'b00;
      cacheP2[8:7] = 3'b00;
      cacheP3[8:7] = 3'b00;
    end //for
  end

	task snoop;
	  input clockt;
	  input [2:0]bust;
	  output [2:0]saida0t;
	  output [2:0]saida1t;
	  output [2:0]saida2t;
	  reg [2:0]statet; //|0 = shared |1=Invalid |2=Exclusive
	  reg [2:0]signalt;

	  /*----------------------------
	  bust:
	  1:read miss	3:read hit
	  2:write mis	4:write hit

	  Sinal:
	  1:Place read miss on bust
	  2:Place write miss on bust

	  3:Place read miss on bust: WB-block
	  4:Place write miss on bust: WB-cashe block
	  5:Place Invalidate on bust
	  ----------------------------*/
	  begin
	  saida0t = statet;
	  saida1t = bust;
	  saida2t = signalt;

	  if(clockt == 1) begin
		 signalt = 3'b000;
		 case(statet)
			0:begin //shared
			  case(bust)
				 1:begin //read miss
						signalt = 3'b001; //place read miss on bust
					end
				 2:begin //write miss
					  signalt = 3'b010; //place writemiss on bust
					  statet = 3'b010;  //shared -> exclusive
					end
				 4:begin //write hit
					  signalt = 3'b101; //place invalidate on bust
					  statet = 3'b010;  //shared -> exclusive
					end
			  endcase
			end
			1:begin //invalid
			  case(bust)
				 1:begin //read miss
					  signalt = 3'b001; //place read miss on bust
					  statet = 3'b000;  //invalid -> shared
					end
				 3:begin //read hit
					  signalt = 3'b001; //place read miss on bust
					  statet = 3'b000;  //invalid -> shared
					end
				 2:begin //write miss
					  signalt = 3'b010; //place write miss on bust
					  statet = 3'b010;  //invalid ->exclusive
					end
				 4:begin //write hit
					  signalt = 3'b010; //place write miss on bust
					  statet = 3'b010;  //invalid -> exclusive
					end
			  endcase
			end
			2:begin //Exclusive
			  case (bust)
				 1:begin //read miss
					  signalt = 3'b011; //place read miss on bust WB-block
					  statet = 3'b000;  //exclusive -> invalid
					end
				 2:begin //write miss
						signalt = 3'b100; //write miss on bust WB-cash block
					end
			  endcase
			end
		 endcase
		end
	end
	endtask

	task snp;
	  input clockm;
	  input [2:0]busm;
	  output [2:0]saida0m;
	  output [2:0]saida1m;
	  output [2:0]saida2m; //
	  reg [2:0]statem; //|0 = shared |1=Invalid |2=Exclusive
	  reg [2:0]signalm;

	  /*-----------------------------
	  busm:
	  1: Read miss on busm
	  2: Write miss on busm
	  3: Invalidate for this block

	  Sinal:
	  1: Write back block : Abort mem acess
	  ------------------------------*/
     begin
	  saida0m = statem;
	  saida1m = busm;
	  saida2m = signalm;

	  if(clock == 1) begin
	  case(statem)
		4: statem = 2; //place write miss
		3: statem = 1; //place read miss
		5: statem = 3; //place write miss
	  endcase
		 case (statem)
			0:begin //shared
			  case (busm)
				 2:begin //write miss for this block
					  statem = 3'b001; // shared -> invalid
					end
				 3:begin //invalidate for this block
					  statem = 3'b001; //shared -> invalid
					end
			  endcase
			end
			1:begin //do nothing
			end
			2:begin //Exclusive
			  case (busm)
				 1:begin //read miss for this block
					  statem = 3'b000;  // exclusive -> shared
					  signalm = 3'b001; //WB-block : abort mem acess
					end
				 2:begin //write miss for this block
					  statem = 3'b001; //invalid
					  signalm = 3'b001;//WB-block : abort mem acess
					end
				 3:begin
					  statem = 3'b001; //invalid
					end
			  endcase
			end
		 endcase
		end
	end
	endtask

endmodule
