function j = Jaccard(Im1,Im2)
Im1 = (Im1~=0);
Im2 = (Im2~=0);
Num = sum(sum(sum(Im1.*Im2)));
Den = sum(sum(sum(Im1)))+sum(sum(sum(Im2)))-Num;
j = Num/Den;
