module projeto(clock, entrada, saida0, saida1,saida2, signal, signal2, 
               stateDest, stateOri, processador, cacheP1, cacheP2, 
               cacheP3, memoria, data, achei, inst);

  input clock;
  input [9:0]entrada;
  input [2:0]saida0, saida1, saida2;
  integer i;

  input [2:0]signal;  //fala
  input [2:0]signal2; //escuta
  input [2:0]stateDest;
  input [2:0]stateOri;
  input [1:0]processador;
  input [8:0]cacheP1;
  input [8:0]cacheP2;
  input [8:0]cacheP3;
  input [3:0]memoria;
  input [3:0]data;
  input achei;
  input inst;
endmodule  