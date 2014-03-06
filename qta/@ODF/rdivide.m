function odf = rdivide(odf,s)
% scaling of the ODF
%
% overload the ./ operator, i.e. one can now write @ODF ./ [1 2 3]  in order
% to scale an ODF by different factors
%
%% See also
% ODF_index ODF/plus ODF/mtimes

argin_check(odf,'ODF');
argin_check(s,'double');

if length(s) == 1, s = repmat(s,size(odf));end

for i = 1:length(odf)
  odf(i).c_hat = odf(i).c_hat ./ s(i);
  odf(i).c = odf(i).c ./ s(i);
end
