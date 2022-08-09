function [out_f, out_fun] = fitnextrap(f,in_fun,ord)


fx=f(end);
FUNLIM=0.1;
TOL=1e-6;

lastdec=log10(f(end));

NDEC=4;
for o=1:ord

    fun=abs(in_fun(:,o));
    A=fun(end);
    for k=1:NDEC
        new_freq(k)=10^(lastdec+k);
        fun_extrap(k)=A*(fx/new_freq(k))^(NDEC*.1);
    end
    ff=[f; new_freq(1:end)'];
    new_freq_siz=length(ff);
    out_fun(:,o)=[fun; fun_extrap(1:end)'];
                    figure(11);semilogx(f,abs(fun),'ko');hold all;semilogx(ff,abs(out_fun));
end
%     out_fun=reshape([out_fun],[new_freq_siz,ord]);

out_f=ff;

end