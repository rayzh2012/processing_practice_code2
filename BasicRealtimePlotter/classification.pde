void testNeuralNetwork(NeuralNetwork nnet, double[] tset) {

  //for (DataSetRow dataRow : tset.getRows()) {

   //nnet.setInput(dataRow.getInput());
   nnet.setInput(tset);
  
    nnet.calculate();
    double[ ] networkOutput = nnet.getOutput();
   // System.out.print("Input: " + Arrays.toString(dataRow.getInput()) );
    System.out.println(" Output: " + Arrays.toString(networkOutput) );

 // }
  
}
