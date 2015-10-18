# MATLAB Fall 2015 – Research Plan

> * Group Name: The friendly prisoners
> * Group participants names: Byungsoo Kim, Basile Maret
> * Project Title: Influence of success-driven and reputation-based migration in the evolution of cooperation.

## General Introduction

Many studies have tried to explain the evolution of cooperation among unrelated individuals. It has been shown that success-driven migration with imitating superior strategies, or reputation-based migration will promote cooperation where individuals pursue selfishness. Most of the time, in real life, more than one factor play a role at the same time and we will model how the combination of success-driven and reputation-based migration will influence the evolution of cooperation.

We believe that cooperation will also be promoted in this model and it will be interesting to see how success-driven and reputation-based migration relate to each other.


## The Model

#### Prisoner's Dilemma

We will use the well known prisoner's dilemma game in a game-theoretical way. In this game, the players can take an action among two options: either cooperate or defect. According to their behavior, there is a payoff which motivate them to defect mutually rather than cooperate. It is represented by the payoff matrix below.

![alt tag](https://github.com/pec0ra/cooperation/blob/master/other/pd_payoff_matrix.png)

As it described in the above, mutual cooperation gives reward payoff *R* both players, and one defection between two players gives temptation payoff *T* for defector which is larger than *R* so that it induces the player to defect when the opponent cooperates and sucker's payoff *S* for sucker. In case of mutual defection, they will get punishment *P* payoff whish is larger than *S* so that it also induces the player to defect when the opponent defect. In sum, everybody is expected to defect, called the "tragedy of the commons" (Hardin, 1968).

#### Spatial Game with Strategies

We simply model social interactions on the *L* X *L* 2-dimensional spatial grid [1]. There are *N* individuals occupying grid sites, and they interact with *m* direct neighbors (von Neumann neighborhoods). The overall payoff *P* of player *i* at iteration *t* is the sum of each payoffs resulting from binary interactions with all von Neumann neighbors [2], and the respective player "imitate" the strategy of best performing neighbor.

In addition, we will extend this game by "success-driven migration" and "reputation-based migration". Before the imitation step, a player can move to improve their expected overall payoff to empty site within a quadratic area of *(2M+1)* X *(2M+1)* sites (the Moore neighborhood of size *M*, e.g. the 8 neighboring sites for *M* = 1). A player can also evaluate the surrounding environment and decide whether he leaves or not by comparing his reputation and those of his neighbors [3]. Below equations accounts for the reputation effect in mobility.

![alt tag](https://github.com/pec0ra/cooperation/blob/master/other/reputation_eq.png)


## Fundamental Questions

How do success-driven and reputation-based migration influence the evolution of cooperation ?

How do they relate to each other ? How does reputation influence success-driven migration and does it affect it in a favorable way for cooperation ?

What are the necessary conditions for success-driven and reputation-based migration in order to promote cooperation ?


## Expected Results

We believe that these mechanisms will promote cooperation. The reputation will probably help prisoners make better migration which will be favorable for cooperation.


## References 

Helbing, D., & Yu, W. (2009). The outbreak of cooperation among success-driven individuals under noisy conditions. *Proceedings of the National Academy of Sciences, 106*(10), 3680-3685.

Helbing, D., Yu, W., & Rauhut, H. (2011). Self-organization and emergence in social systems: Modeling the coevolution of social environments and cooperative behavior. *The Journal of Mathematical Sociology, 35*(1-3), 177-208.

Cong, R., Wu, B., Qiu, Y., & Wang, L. (2012). Evolution of cooperation driven by reputation-based migration. *PloS one, 7*(5), e35776.


## Research Methods

Game Theory and Agent-Based Model


## Other
