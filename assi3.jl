
using DataFrames, DataFramesMeta, Gadfly, RDatasets,StatsBase,GLM
uk_table  = readtable("/Users/DS/Downloads/EelctionData/UK2010.csv")
russia_table1 = readtable("/Users/DS/Downloads/EelctionData/Russia2011/Russia2011_1of2.csv")
russia_table2 = readtable("/Users/DS/Downloads/EelctionData/Russia2011/Russia2011_2of 2.csv")

#combining 2 russia table using vcat
names!(russia_table2,[Symbol(russia_table1.colindex.names[i]) for i in 1:size(russia_table1,2)])
russia_table = vcat(russia_table1,russia_table2)
#show(uk_table)
#show(russia_table)


#PART 1
#Q-1

#removing invalid data
uk_table = uk_table[~isna(uk_table[:,:Press_Association_Reference]),:]
russia_table = russia_table[~isna(russia_table[:,:Code_for_district]),:]

#changing values for NA to 0
for i in 4 : size(uk_table,2)
    uk_table[isna(uk_table[i]),i] = 0.0
end
show(uk_table)

#Q-2
#a
sum(uk_table[:Electorate])
sum(russia_table[:Number_of_voters_included_in_voters_list])

#b
sum(uk_table[:Votes])
sum(russia_table[:Number_of_valid_ballots])

#c
winner_uk = 0
count_uk = 0
for i in 7:size(uk_table,2)
  if count_uk < sum(uk_table[i])
     winner_uk = i
     w=count_uk = sum(uk_table[i])
   end
end
winner_uk

winner_russia  = 0
count_russia = 0
length = size(russia_table,2)
for i in length-6:length
  if count_russia < sum(russia_table[i])
    winner_russia =  i
    count_russia = sum(russia_table[i])
  end
end
winner_russia

#d
mean_uvoters_df = DataFrame(mean_uk_voters = mean(uk_table[:Electorate]),var_uk_voters = var(uk_table[:Electorate]))
show(mean_uvoters_df)

mean_rvoters_df = DataFrame(mean_russia_voters = mean(russia_table[:Number_of_voters_included_in_voters_list]),var_russia_voters = var(russia_table[:Number_of_voters_included_in_voters_list]))
show(mean_rvoters_df)

#e
plot(uk_table, x= "Electorate",Geom.histogram())
plot(russia_table,x="Number_of_voters_included_in_voters_list",Geom.histogram())

#f
mean_uvotes_df=DataFrame(mean_uk_votes = mean(uk_table[:Votes]),var_uk_votes = var(uk_table[:Votes]))
show(mean_uvotes_df)

mean_rvotes_df=DataFrame(mean_russia_votes = mean(russia_table[:Number_of_valid_ballots]),var_russia_votes = var(russia_table[:Number_of_valid_ballots]))
show(mean_rvotes_df)


#Q-3
# For Sanity Check

uk_sanity_count  = 0
for i in 1 : size(uk_table,1)
  temp1  = 0
  for j in 7:size(uk_table,2)
        temp1 += uk_table[i,j]
  end
  if temp1 != uk_table[i,:6]
    uk_sanity_count += 1
  end
end
uk_sanity_count

russia_sanity_count  = 0
for i in 1 : size(russia_table,1)
  temp2  = 0
  for j in size(russia_table,2) - 6:size(russia_table,2)
        temp2 += russia_table[i,j]
  end
  if temp2 != russia_table[i,:Number_of_valid_ballots]
    russia_sanity_count += 1
  end
end
russia_sanity_count


#Q-4
#a
uk_df_turn = uk_table[1:6]
uk_df_turn[:turnout_rate] = 0.0

for i in 1:size(uk_df_turn,1)
  uk_df_turn[i,7] = uk_df_turn[i,6] / uk_df_turn[i,5]
end
show(uk_df_turn)
plot(uk_df_turn, x="turnout_rate",Geom.histogram())

r_df_turn = russia_table[:,[:Number_of_voters_included_in_voters_list,:Number_of_valid_ballots] ]
r_df_turn[:turnout_rate] = 0.0

for i in 1:size(r_df_turn,1)
  r_df_turn[i,:turnout_rate] = r_df_turn[i,2] / r_df_turn[i,1]
end

show(r_df_turn)
names(r_df_turn)
plot(r_df_turn, x="turnout_rate",Geom.histogram())

#b
won_vote_df = DataFrame(ID=uk_table[:Press_Association_Reference],winVotes=0)
show(won_vote_df)
for i in 1:size(uk_table,1)
    won_vote_df[i,:winVotes] = uk_table[i,:Con] + uk_table[i,:LD]
end
show(won_vote_df)

#c
uk_scatter_plot = hcat(uk_df_turn,won_vote_df)
uk_scatter_plot[:winrate] = 0.0
for i in 1:size(uk_scatter_plot,1)
  uk_scatter_plot[i,:winrate] = uk_scatter_plot[i,:winVotes] / uk_scatter_plot[i,:Votes]
end
show(uk_scatter_plot)
plot(uk_scatter_plot,x="turnout_rate",y="winrate",color="Region",Geom.point)

r_scatter_plot = hcat(r_df_turn,russia_table[winner_russia],russia_table[:Name_of_district])
#show(r_scatter_plot)
r_scatter_plot[:winrate] = 0.0
rename!(r_scatter_plot,:x1,:winVote)
rename!(r_scatter_plot,:x1_1,:Region)
show(r_scatter_plot)
for i in 1:size(r_scatter_plot,1)
  r_scatter_plot[i,:winrate] = r_scatter_plot[i,:winVote] / r_scatter_plot[i,:Number_of_valid_ballots]
end
plot(r_scatter_plot,x="turnout_rate",y="winrate",color="Region",Geom.point)

#d
rand_sample =  r_scatter_plot[1,:]
i = 0
len = size(r_scatter_plot,1)
range = 200
while (range*i+range) < len
    index = rand(range*i+1:range*i+range)
    append!(rand_sample,r_scatter_plot[index,:])
    i += 1
end

show(r_scatter_plot[1,:])
show(rand_sample)
plot(rand_sample,x="turnout_rate",y="winrate",color="Region",Geom.point)



#PART-2
using GLM
#Q-1
gpa_gre_df = readtable("/Users/DS/Downloads/gpa-gre.csv")
#show(gpa_gre_df)
deleterows!(gpa_gre_df,find(isna(gpa_gre_df[:,:Verbal])))
plot(gpa_gre_df,x="Year",y="GPA",Geom.boxplot)
show(gpa_gre_df)


#Q-2
#a
cor(gpa_gre_df[:GPA],gpa_gre_df[:Quant])
cor(gpa_gre_df[:GPA],gpa_gre_df[:Verbal])
cor(gpa_gre_df[:GPA],gpa_gre_df[:Verbal]+gpa_gre_df[:Quant])

#b
gpa_lm = lm(GPA ~ Quant, gpa_gre_df)
show(gpa_lm)

#c
fitted_f(x) = 0.000988079*x + 2.75867
plot(layer(gpa_gre_df,x="Quant",y="GPA",Geom.point),
 layer(fitted_f,minimum(gpa_gre_df[:Quant]),maximum(gpa_gre_df[:Quant])),
 Guide.XLabel("X"),Guide.YLabel("Y"))

#d
plot(x=residuals(gpa_lm),y=gpa_gre_df[:GPA],Geom.point,Guide.XLabel("Residuals"),Guide.YLabel("GPA"))
residuals(gpa_lm)

#e
r2(gpa_lm)

#f
gpa_lm_both = lm(GPA ~ Quant + Verbal, gpa_gre_df)
show(gpa_lm_both)
coef(gpa_lm_both)

#g
r2(gpa_lm_both)
