library(ggplot2)
library(cowplot)

db.dat <- read.table('Database_Creation_Stats_Summary.txt', header=T, sep='\t')
# method  time_minutes    final_diskspace_gb      max_memory_gb

fz.dat <- read.table('Gene_Cluster_Search_Stats_Summary.txt', header=T, sep='\t')
# color   method  time_minutes    gc_identified   max_memory_gb

fz.rp.dat <- read.table('Ribo_Gene_Cluster_Search_Stats_Summary.txt', header=T, sep='\t')
# color   method  time_minutes    gc_identified   max_memory_gb

db_colors <- c("#bd3552", "#785f96", "#76a82a")
names(db_colors) <- c("zol", "gator-gc", "cblaster")

search_colors <- c("#bd3552", "#785f96", "#76a82a")
names(search_colors) <- c("zol", "gator-gc", "cblaster")

png("Database_Creation_Stats_Summary.png", height=3.5, width=15, units='in', res=600)
g1 <- ggplot(db.dat, aes(x=reorder(method, time_minutes), y=time_minutes, fill=color)) + ggtitle("Runtime (minutes)") + geom_bar(stat='identity', color='black', show.legend=F) + theme_bw() + ylab("") + xlab("Method") + scale_fill_manual(values=db_colors) + coord_flip()
g2 <- ggplot(db.dat, aes(x=reorder(method, final_diskspace_gb), y=final_diskspace_gb, fill=color)) + ggtitle("Final diskspace (GB)") + geom_bar(stat='identity', color='black', show.legend=F) + theme_bw() + ylab("") + xlab("Method") + scale_fill_manual(values=db_colors) + coord_flip()
g3 <- ggplot(db.dat, aes(x=reorder(method, max_memory_gb), y=max_memory_gb, fill=color)) + ggtitle("Maximum resident set size (GB)") + geom_bar(stat='identity', color='black', show.legend=F) + theme_bw() + ylab("") + xlab("Method") + scale_fill_manual(values=db_colors) + coord_flip()
plot_grid(g1, g2, g3, ncol=3)
dev.off()

png("Gene_Cluster_Search_Stats_Summary_Both.png", height=3.5, width=15, units='in', res=600)
g1 <- ggplot(fz.dat, aes(x=reorder(method, time_minutes), y=time_minutes, fill=color)) + ggtitle("Runtime (minutes)") + geom_bar(stat='identity', color='black', show.legend=F) + theme_bw() + ylab("") + xlab("Method") + scale_fill_manual(values=search_colors) + coord_flip()
g2 <- ggplot(fz.dat, aes(x=reorder(method, gc_identified), y=gc_identified, fill=color)) + ggtitle("Gene clusters identified") + geom_bar(stat='identity', color='black', show.legend=F) + theme_bw() + ylab("") + xlab("Method") + scale_fill_manual(values=search_colors) + coord_flip()

g3 <- ggplot(fz.rp.dat, aes(x=reorder(method, time_minutes), y=time_minutes, fill=color)) + ggtitle("Runtime (minutes)") + geom_bar(stat='identity', color='black', show.legend=F) + theme_bw() + ylab("") + xlab("Method") + scale_fill_manual(values=search_colors) + coord_flip()
g4 <- ggplot(fz.rp.dat, aes(x=reorder(method, gc_identified), y=gc_identified, fill=color)) + ggtitle("Gene clusters identified") + geom_bar(stat='identity', color='black', show.legend=F) + theme_bw() + ylab("") + xlab("Method") + scale_fill_manual(values=search_colors) + coord_flip()
plot_grid(g1, g2, g3, g4, ncol=4)
dev.off()
