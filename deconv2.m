function D = deconv2(C,A)
    % DECONV2 - Deconvolute an MxN convolution, C, using an input convolution
    % of the same size, A.
    
    Cshift = fftshift(C);
    Ashift = fftshift(A);
    
    D = ifftshift(ifft2(fft2(Cshift)./fft2(Ashift)));

end