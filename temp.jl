
using DataFrames,DataFramesMeta, Gadfly, RDatasets
UKBallot  = readtable("/Users/DS/Downloads/EelctionData/UK2010.csv")
RussinBallot1 = readtable("/Users/DS/Downloads/EelctionData/Russia2011/Russia2011_1of2.csv")
RussinBallot2 = readtable("/Users/DS/Downloads/EelctionData/Russia2011/Russia2011_2of 2.csv")

names!(RussinBallot2, [ Symbol(RussinBallot1.colindex.names[i]) for i in 1:size(RussinBallot1,2)])
RussianBallot = vcat(RussinBallot1,RussinBallot2)

UKBallot = UKBallot[~isna(UKBallot[:,:Press_Association_Reference]),:]
RussianBallot = RussianBallot[~isna(RussianBallot[:,:Code_for_district]),:]

for i in 4 : size(UKBallot,2)
    UKBallot[isna(UKBallot[i]),i] = 0.0
end

#question 2
#a
sum(UKBallot[:Electorate])
sum(RussianBallot[:Number_of_voters_included_in_voters_list])
#b
sum(UKBallot[:Votes])
sum(RussianBallot[:Number_of_valid_ballots])
#c
UKWinner = 0
UKWinCount = 0
for i in 7:size(UKBallot,2)
  if UKWinCount < sum(UKBallot[i])
     UKWinner = i
     w=UKWinCount = sum(UKBallot[i])
   end
end
UKWinner

RWinner  = 0
RWinCount = 0
length = size(RussianBallot,2)
for i in length-6:length
  if RWinCount < sum(RussianBallot[i])
    RWinner =  i
    RWinCount = sum(RussianBallot[i])
  end
end
RWinner
#d

#UKDistrict = by(UKBallot, :Region) do UKBallot
DataFrame(mean = mean(UKBallot[:Electorate]),
  s² = var(UKBallot[:Electorate]),
  sum = sum(UKBallot[:Electorate]))
#end

#RDistrict  = by(RussianBallot, :Code_for_district) do RussianBallot
DataFrame(mean = mean(RussianBallot[:Number_of_voters_included_in_voters_list]),
     s² = var(RussianBallot[:Number_of_voters_included_in_voters_list]),
     sum = sum(RussianBallot[:Number_of_voters_included_in_voters_list]))
#end

#e
#plot(UKDistrict, x = "sum",Geom.histogram())
#plot(RDistrict, x= "sum", Geom.histogram())
plot(UKBallot, x= "Electorate",Geom.histogram())
plot(RussianBallot,x="Number_of_voters_included_in_voters_list",Geom.histogram())
#f
#by(UKBallot, :Region) do UKBallot
DataFrame(mean = mean(UKBallot[:Votes]),
     s² = var(UKBallot[:Votes]))
#end

#by(RussianBallot, :Code_for_district) do RussianBallot
DataFrame(mean = mean(RussianBallot[:Number_of_valid_ballots]),
     s² = var(RussianBallot[:Number_of_valid_ballots]))
#end

##question 3. Sanity Check
UK_SanityCount  = 0
location = 0
for i in 1 : size(UKBallot,1)
  temp  = 0
  for j in 7:size(UKBallot,2)
        temp += UKBallot[i,j]
  end
  if temp != UKBallot[i,:6]
    UK_SanityCount += 1
    location = i
  end
end
UK_SanityCount
location

R_SanityCount  = 0
for i in 1 : size(RussianBallot,1)
  temp  = 0
  for j in size(RussianBallot,2) - 6:size(RussianBallot,2)
        temp += RussianBallot[i,j]
  end
  if temp != RussianBallot[i,:Number_of_valid_ballots]
    R_SanityCount += 1
  end
end
R_SanityCount
#Question 4
#a
#groupDf = by(df2, :Region) do df2
DataFrame(turnoutRate = UKBallot[:Votes])
#end

uk_turnDf = UKBallot[1:6]
uk_turnDf[:turnoutRate] = 0.0

for i in 1:size(uk_turnDf,1)
  uk_turnDf[i,7] = uk_turnDf[i,6] / uk_turnDf[i,5]
end
uk_turnDf
plot(uk_turnDf, x="turnoutRate",Geom.histogram())

r_turnDf = RussianBallot[:,[:Number_of_voters_included_in_voters_list,:Number_of_valid_ballots] ]
r_turnDf[:turnoutRate] = 0.0

for i in 1:size(r_turnDf,1)
  r_turnDf[i,:turnoutRate] = r_turnDf[i,2] / r_turnDf[i,1]
end

r_turnDf
names(r_turnDf)
plot(r_turnDf, x="turnoutRate",Geom.histogram())

#b
wonVoteDataFrame = DataFrame(ID=UKBallot[:Press_Association_Reference],winVotes=0)
wonVoteDataFrame
for i in 1:size(UKBallot,1)
    wonVoteDataFrame[i,:winVotes] = UKBallot[i,:Con] + UKBallot[i,:LD]
end
#c
uk_scatter = hcat(uk_turnDf,wonVoteDataFrame)
uk_scatter[:winrate] = 0.0
for i in 1:size(uk_scatter,1)
  uk_scatter[i,:winrate] = uk_scatter[i,:winVotes] / uk_scatter[i,:Votes]
end
plot(uk_scatter,x="turnoutRate",y="winrate",color="Region",Geom.point)

r_scatter = hcat(r_turnDf,RussianBallot[RWinner],RussianBallot[:Name_of_district])
r_scatter[:winrate] = 0.0
 rename!(r_scatter,:x1,:winVote)
rename!(r_scatter,:x1_1,:Region)
r_scatter
for i in 1:size(r_scatter,1)
  r_scatter[i,:winrate] = r_scatter[i,:winVote] / r_scatter[i,:Number_of_valid_ballots]
end
plot(r_scatter,x="turnoutRate",y="winrate",color="Region",Geom.point)


#d
r_sample =  r_scatter[1,:]
  i = 0
  len = size(r_scatter,1)
  range = 100
  while (range*i+range) < len
    index = rand(range*i+1:range*i+range)
    append!(r_sample,r_scatter[index,:])
    i += 1
  end
r_sample
plot(r_sample,x="turnoutRate",y="winrate",color="Region",Geom.point)

#1.
gpaDf = readtable("/Users/DS/Downloads/gpa-gre.csv")
plot(gpaDf,x="Year",y="GPA",Geom.boxplot)
gpaDf

deleterows!(gpaDf,find(isna(gpaDf[:,:Verbal])))
using GLM
#2
#a
cor(gpaDf[:GPA],gpaDf[:Quant])
cor(gpaDf[:GPA],gpaDf[:Verbal])
cor(gpaDf[:GPA],gpaDf[:Verbal]+gpaDf[:Quant])

#b
gpaLM = lm(GPA ~ Quant, gpaDf)
show(gpaLM)
#plot(layer(near_exact_data,x="X",y="Y",Geom.point),
 ##uide.XLabel("X"),Guide.YLabel("Y"))
plot(x=residuals(gpaLM),y=gpaDf[:GPA],Geom.point,Guide.XLabel("Residuals"),Guide.YLabel("GPA"))
residuals(gpaLM)
#e
r2(gpaLM)
min_max_norm(x) = (x - minimum(x)) / (maximum(x) - minimum(x))
#model = glm(GPA~Quant,gpaDf,Binomial(),LogitLink())
fitted_f(x) = 0.000988079*x + 2.75867
plot(layer(gpaDf,x="Quant",y="GPA",Geom.point),
 layer(fitted_f,minimum(gpaDf[:Quant]),maximum(gpaDf[:Quant])),
 Guide.XLabel("X"),Guide.YLabel("Y"))


greLM = lm(GPA ~Quant + Verbal,gpaDf)
show(greLM)
coef(greLM)
r2(greLM)
