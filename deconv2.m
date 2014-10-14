function D = deconv2(C,A)

    Cshift = fftshift(C);
    Ashift = fftshift(A);
    
    D = ifftshift(ifft2(fft2(Cshift)./fft2(Ashift)));
end