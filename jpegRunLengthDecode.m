function decodedSymbols = runLengthDecode(encodedSymbols)
    decodedSymbols = [];
    
    for i = 1:2:length(encodedSymbols)
        count = encodedSymbols(i);
        symbol = encodedSymbols(i+1);
        
        decodedSymbols = [decodedSymbols repmat(symbol, 1, count)];
    end
end