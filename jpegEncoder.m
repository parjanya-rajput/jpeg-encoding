function jpegEncoder(image)
    % Convert image to YCbCr color space
    ycbcrImage = rgb2ycbcr(image);

    %Display YCbCr image
    figure, imshow(ycbcrImage), title("YCBCR");
    
    % Split YCbCr channels
    Y = ycbcrImage(:, :, 1);
    Cb = ycbcrImage(:, :, 2);
    Cr = ycbcrImage(:, :, 3);
    
    %Show Y,Cb and Cr Components
    figure, subplot(2,2,1), imshow(Y), title("Y Component");
    figure, subplot(2,2,2), imshow(Cb), title("Cb Component");
    figure, subplot(2,2,3), imshow(Cr), title("Cr Component");
    % Downsample Cb and Cr channels
    Cb = imresize(Cb, 0.5);
    Cr = imresize(Cr, 0.5);
    
    % Apply DCT to Y, Cb, and Cr channels
    Y_dct = blockproc(Y, [8 8], @(block_struct) dct2(block_struct.data));
    Cb_dct = blockproc(Cb, [8 8], @(block_struct) dct2(block_struct.data));
    Cr_dct = blockproc(Cr, [8 8], @(block_struct) dct2(block_struct.data));

    figure, subplot(2,2,1), imshow(Y_dct), title("Y-DCT Component");
    figure, subplot(2,2,2), imshow(Cb_dct), title("Cb-DCT Component");
    figure, subplot(2,2,3), imshow(Cr_dct), title("Cr-DCT Component");

    quantizationMatrix = [...
        16  11  10  16  24  40  51  61;...
        12  12  14  19  26  58  60  55;...
        14  13  16  24  40  57  69  56;...
        14  17  22  29  51  87  80  62;...
        18  22  37  56  68 109 103  77;...
        24  35  55  64  81 104 113  92;...
        49  64  78  87 103 121 120 101;...
        72  92  95  98 112 100 103  99];
    
    % Quantize Y, Cb, and Cr channels
    Y_quantized = blockproc(Y_dct, [8 8], @(block_struct) round(block_struct.data ./ (quantizationMatrix * 8)));
    Cb_quantized = blockproc(Cb_dct, [8 8], @(block_struct) round(block_struct.data ./ (quantizationMatrix * 8)));
    Cr_quantized = blockproc(Cr_dct, [8 8], @(block_struct) round(block_struct.data ./ (quantizationMatrix * 8)));
    
    figure, subplot(2,2,1), imshow(Y_quantized), title("Y-Quantized");
    figure, subplot(2,2,2), imshow(Cb_quantized), title("Cb-Quantized");
    figure, subplot(2,2,3), imshow(Cr_quantized), title("Cr-Quantized");

    %If error appears we need to resize the matrix as a multiple of 8

    % Zigzag reordering
    Y_zigzag = blockproc(Y_quantized, [8 8], @(block_struct) zigzagScan(block_struct.data));
    Cb_zigzag = blockproc(Cb_quantized, [8 8], @(block_struct) zigzagScan(block_struct.data));
    Cr_zigzag = blockproc(Cr_quantized, [8 8], @(block_struct) zigzagScan(block_struct.data));
    
    % Run-length encoding
    Y_rle = jpegRunLengthEncode(Y_zigzag);
    Cb_rle = jpegRunLengthEncode(Cb_zigzag);
    Cr_rle = jpegRunLengthEncode(Cr_zigzag);
    
    % Save encoded data to a file
    save('encoded_data.mat', 'Y_rle', 'Cb_rle', 'Cr_rle');
end