<!-- this file is edited by hand -->

[//]: # (gen-title: NFL Elo F.A.Q.)

[//]: # (gen-title-url: NFL-Elo-FAQ)

[//]: # (gen-keywords: NFL, Elo ratings, FAQ)

[//]: # (gen-description: Frequently asked questions about my NFL Elo ratings.)

[//]: # (gen-meta-end)

<style>
	.top-arw {
		opacity: 0.5;
		text-decoration: none !important;
		font-size: 0.9rem;
	}
	h3 {
		margin-top: 4.0rem;
		border-bottom: 2px solid rgba(90, 90, 90, 0.5);
		padding-bottom: 0.4rem;
	}
}
</style>

# NFL Elo F.A.Q.

<!-- grep h3 gen/static/nfl-elo/faq.md | grep top-arw | cut -d '"' -f 9,2 | pbcopy -->

* [What are Elo ratings?](#Elo-Ratings)
* [How do Elo ratings work for the NFL?](#NFL-Elo-Ratings)
* [Why are you publishing these?](#Why-Publish)
* [What are the goals of these NFL Elo ratings?](#Goals)
* [Why be objective?](#Why-Objective)
* [How can the "accuracy" of these Elo ratings be judged?](#Define-Accurate)
* [How are these Elo ratings "objective?"?](#Define-Objective)
* [What are the model parameters?](#Define-Parameters)
* [What data is used to calculate these Elo ratings?](#Data)
* [How accurate are these ratings?](#How-Accurate)
* [The NFL only has 17 games in a season, and every year there is a lot of roster and coach turnover.  How can Elo ratings be effective for the NFL?](#Small-Sample-Size)
* [Why don't these Elo ratings use QB stats?  Or player injuries?  Or offense or defense EPA stats?  Or other stats?](#Why-Not-Use-More-Stats)
* [Why use margin of victory?  The object of the game is to win, not to win by a wide margin.](#Why-Use-Margin-of-Victory)
* [How can margin of victory be used when a 30-point win may be no better than a 20-point win?](#What-Is-a-Big-Win)
* [Why are the ratings so slow to update?  Team XYZ has won several games recently, and they're not highly rated.](#Why-Do-Ratings-Move-So-Little)
* [Team XYZ gained too many rating points for beating an injured team.  How is this accounted for?](#Injury-Bump)
* [Why is Team XYZ in the top 5?  They've played terribly the last few weeks.](#Team-Terrible-Lately)
* [Why is Team XYZ in the top 5?  They have a losing record.](#Rating-Does-Not-Match-Bad-Record)
* [Why is Team XYZ ranked so low?  They have a great record.](#Rating-Does-Not-Match-Good-Record)
* [Why do last season's ratings matter so much?  This is a new season.](#Why-Not-Blank-Slate)
* [Team A played Team B.  Team A appears to have gained more Elo rating points than Team B lost.  Shouldn't they be the same?](#Elo-Exchanged-Appears-To-Not-Be-Net-Zero)
* [Are these Elo ratings biased toward Team XYZ?  Or against Team XYZ?](#Are-These-Biased-For-Team)
* [Where can I see discussion of these ratings each week?](#Where-Is-Discussion)
* [Why was the model changed?](#Why-Was-The-Model-Changed)
* [I have a comment, feedback, or suggestion.  How can I get in touch?](#Comment-Feedback-Suggestion)



<h3><a name="Elo-Ratings"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> What are Elo ratings?</h3>

Elo ratings are numeric strength ratings for a set of competitors (see <a target="_blank" href="https://en.wikipedia.org/wiki/Elo_rating_system">Wikipedia</a>) where higher scores are better.  For example, competitor "A" with an Elo rating of 1,650 is considered stronger than "B" with a rating of 1,600.  This allows us to judge the strength of two competitors that haven't recently, or ever, had a head-to-head match using one number: their Elo rating.

The *expected* outcome of a contest between any two contestants can be calculated using their ratings.  After a match, the contestant that exceeds expectations takes some amount of Elo rating points from their opponent.  For the example ratings, if the weaker contestant "B" beats "A" convincingly, they may take 30 Elo rating points.  "B" would then be rated 1,630 and "A" would then be rated 1,620.

While originally invented for rating chess players, Elo ratings and similar systems are used in many areas.

<h3><a name="NFL-Elo-Ratings"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> How do Elo ratings work for the NFL?</h3>

In applying Elo ratings to American football, we cannot treat an NFL game like a single chess game.  A chess game can be won or lost in only a few moves, and the endgame is determined by which pieces remain and where they are physically positioned.  This is more analogous to a football drive or even a single play than to an entire football game.

Instead, we'll treat a football game like a multi-game chess match.  After a scoring drive, a football team kicks to their opponent and a new drive begins &mdash; to some degree the game is reset.  Nothing like this happens in a single chess game but it lines up nicely with a multi-game chess match.

In a chess match, player ratings are used to compute the expected winning percentage of games for both players.  An expected performance of 0.5 means a player is expected to win as many games as they lose, and draw the rest.  For football, we can consider each game as a series of drives (or plays). If one team "wins" most of the drives within a game, they'll likely end up with a large margin of victory. If both teams "win" the same number of drives, the margin of victory will likely be much more narrow.  Therefore, team ratings can be used to calculate an expected margin of victory for the favored team.  For example, if both teams are expected to score 0.5, a tie is expected.  If one team is expected to score a perfect 1.0, they are expected to win by a "blowout" margin (more on that later).  After a game, the two teams' Elo ratings are adjusted based on the actual vs. expected margin of victory.

<h3><a name="Why-Publish"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> Why are you publishing these?</h3>

<a target="_blank" href="https://web.archive.org/web/20230214003629/https://projects.fivethirtyeight.com/2022-nfl-predictions/">FiveThirtyEight had NFL Elo ratings</a>, and they were fun to watch over the course of a season.  Their Elo ratings stopped being updated after the 2022 season.  When the 2023 season began, I missed checking the Elo ratings enough to make my own.  I published <a target="_blank" href="https://old.reddit.com/r/nfl/comments/1704tdu/nfl_week_5_elo_power_rankings_oc/">the first weekly update to reddit</a> following week 5 of the 2023 season.

<h3><a name="Goals"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> What are the goals of these NFL Elo ratings?</h3>

These NFL Elo ratings are intended to be simple, objective, and as accurate as possible.

<h3><a name="Why-Objective"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> Why be objective?</h3>

Human-written power rankings have value, but their authors may have some bias, unconscious or otherwise, that affects their power rankings.  Elo-based ratings and rankings can reduce or eliminate biases for or against individual teams.

I believe that If I do any subjective model tuning to make the ratings "look more correct" to my eye, then I am nearly 100% likely to be making the model less accurate, or more biased in some way, or both.  I want to avoid this altogether.

There are plenty of power rankings designed by their authors to look correct to their eye.  (Reddit user <a target="_blank" href="https://old.reddit.com/user/mikebiox/submitted/?sort=new">mikebiox</a> has been posting weekly <a target="_blank" href="https://old.reddit.com/r/nfl/comments/1oua20x/nfl_power_rankings_combined_week_10/">averaged power rankings for years</a> if you're interested in those.)  There's no point in replicating any of that here, so these Elo ratings are intended to be objective.

<h3><a name="Define-Accurate"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> How can the "accuracy" of these Elo ratings be judged?</h3>

These Elo ratings take a few factors into account, including home field advantage and rest days, to calculate expected winners for each game.  Models that pick more game winners correctly are considered more accurate.  To avoid overfitting to individual seasons, the standard deviation of the pick rate across seasons is also used: models that pick game winners more consistently from season to season are considered more accurate.

As a benchmark, the model pick rates can be [compared to Vegas's straight-up pick rates](#How-Accurate).

<h3><a name="Define-Objective"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> How are these Elo ratings "objective?"</h3>

Simply put: the model is tuned to match the average case over thousands of NFL games over 31 seasons.

The ratings are calculated with <a target="_blank" href="https://en.wikipedia.org/wiki/Elo_rating_system#Mathematical_details">regular Elo rating math</a>, but things like the "K-factor," home field advantage, how to define a close win vs. a blowout win, etc., are [parameters](#Define-Parameters) that must be set to *something*.

To be "objective" we set the model parameters, and [see how accurate the model is](#Define-Accurate) compared to the best known models.  Then, of course, we simply go with whatever model is most accurate.

Initially during the 2023 season, I tried tuning these parameters by hand to find the most accurate model I could.  I quickly found this to be an impossible task, and by the 2024 offseason <a target="_blank" href="https://philthompson.me/2024/NFL-Elo-Power-Rankings-for-2024.html#embracing-randomness">I was doing automated testing of thousands of models</a> to find the most accurate one from 2012-2023.  Over the 2025 offseason I experimented with <a target="_blank" href="https://optuna.org/">optuna hyperparameter optimization</a>, and ended up <a target="_blank" href="https://philthompson.me/2025/NFL-Elo-Power-Rankings-for-2025.html">testing tens of millions of models</a> against the 1994-2024 seasons, and using optuna to fine-tune the best candidate models.

<h3><a name="Define-Parameters"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> What are the model parameters?</h3>

There are more than 20 parameters for the model including home field advantage, rest days advantage, what constitutes a "blowout" victory, and so on.  The value I've created is in the details here, so I will not be publishing them.

I will continue to make the Elo ratings themselves <a target="_blank" href="https://philthompson.me/nfl-elo/">freely available here, on my website</a>, with no trackers, no cookies, and no ads (and not even any JavaScript!).

<h3><a name="Data"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> What data is used to calculate these Elo ratings?</h3>

The ratings are calculated from:

* margin of victory/defeat,
* home field advantage,
* rest/travel days between games,
* whether an overtime period occurred,
* offseason "parity reset" (reversion to the mean),
* early season shenanigans/uncertainty,
* division alignment (whether a game is a division matchup),
* whether a game is meaningless with respect to playoff seeding,
* and of course both teams' ratings.

<h3><a name="How-Accurate"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> How accurate are these ratings?</h3>

This Elo rating model was tuned by backtesting against 8,200+ games NFL games from 1994 through 2024. Over that span of it correctly picks winners in 65.84% of games, trailing the Vegas straight-up pick rate of 66.63% (according to <a target="_blank" href="https://www.sportsoddshistory.com/nfl-game-odds/">sportsoddshistory.com</a>), though it did meet or exceed Vegas's pick rate in 8 of the past 14 seasons. This model also does well compared to many "experts" on <a target="_blank" href="https://nflpickwatch.com/nfl">NFL Pickwatch</a>. That being said, these ratings and rankings are not intended for use in informing sports betting decisions. This is a simple Elo model derived from a minimal data set and it does not account for many relevant factors that may impact game outcomes. The accuracy of this model for past seasons is not necessarily indicative of its accuracy for the current or future seasons.

<a target="_blank" href="https://philthompson.me/s/img/2025/20250909-By-Season-Vs-Vegas-1994-2024.png">This chart</a> shows the pick rates by season between Vegas and the newest (at the time of writing) Elo models for the 2025 season.

<h3><a name="Small-Sample-Size"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> The NFL only has 17 games in a season, and every year there is a lot of roster and coach turnover.  How can Elo ratings be effective for the NFL?</h3>

I guess it's a bit surprising, but the "slow to update" nature of these Elo ratings was found to give the best accuracy.  This indicates that NFL teams do carry over much of their identity from one season to the next.

The [model's accuracy, compared to Vegas](#How-Accurate), demonstrates this.

<h3><a name="Why-Not-Use-More-Stats"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> Why don't these Elo ratings use QB stats?  Or player injuries?  Or offense or defense EPA stats?  Or other stats?</h3>

Ultimately, I want to keep these ratings simple and traditional.  I believe that incorporating more stats and variables makes the model more susceptible to bias, and makes the model harder to tune for accuracy.  The model's [accuracy](#How-Accurate) is, in my opinion, already very good as-is.

Additionally, it appears that stats, roster changes, etc., don't seem to matter as much as we'd think.  Again, I believe the accuracy of these ratings is proof of that.

<h3><a name="Why-Use-Margin-of-Victory"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> Why use margin of victory?  The object of the game is to win, not to win by a wide margin.</h3>

I am very confident that teams attempt to score on most drives on offense, and try to prevent scores while playing defense.  There are some situations where it's optimal to burn clock or force the opponent to use timeouts, but otherwise I believe teams try to score on every possession.  At the end of the day, the best way to increase your chance of winning is to have a larger lead.

Using margin of victory instead of "expected chance to win" also makes [calculating model accuracy](#Define-Accurate) more straightforward.

<h3><a name="What-Is-a-Big-Win"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> How can margin of victory be used when a 30-point win may be no better than a 20-point win?</h3>

Margin of victory is awarded on a curve.  A 50-point win is not awarded 10 times as much as a 5-point win.  See more background about this curve <a target="_blank" href="https://philthompson.me/2023/NFL-Elo-Power-Rankings-for-2023.html#update-2023-11-15">here</a>.

<h3><a name="Why-Do-Ratings-Move-So-Little"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> Why are the ratings so slow to update?  Team XYZ has won several games recently, and they're not highly rated.</h3>

Like all aspects of this system, the model appears to be slow to update because that [results in the most correctly-picked games, on average](#Define-Objective).

One interpretation of this is that games (especially close games) are often won or lost due in part to factors not related to the underlying "true strength" of a team: sometimes they play at a stronger or weaker level depending on injuries, opponent, game plan, individual matchups between players, play calling, and even weather and field conditions, and there are also simple flukes and odd bounces of the ball.  The best the model can do is shoot for the average case and try not to over-react to individual games.

<h3><a name="Injury-Bump"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> Team XYZ gained too many rating points for beating an injured team.  How is this accounted for?</h3>

If a team is actually overrated (which does happen), they will by definition then *under* perform (as far as the model's concerned) in subsequent weeks (barring strange circumstances where a team benefits from this in successive weeks).  This will drag their rating back down.

<h3><a name="Team-Terrible-Lately"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> Why is Team XYZ in the top 5?  They've played terribly the last few weeks.</h3>

See [above](#Why-Do-Ratings-Move-So-Little).

<h3><a name="Rating-Does-Not-Match-Bad-Record"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> Why is Team XYZ in the top 5?  They have a losing record.</h3>

Elo ratings are intended to be informative about any hypothetical matchup today, not predict which teams will make the playoffs or win the Super Bowl.

A team's Elo rating is the predictor for how strong they are, not their record.  Strong teams often have good records, but not always.

<h3><a name="Rating-Does-Not-Match-Good-Record"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> Why is Team XYZ ranked so low?  They have a great record.</h3>

See [above](#Rating-Does-Not-Match-Bad-Record).

<h3><a name="Why-Not-Blank-Slate"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> Why do last season's ratings matter so much?  This is a new season.</h3>

Like other parameters in this system, the impact of the offseason parity reset and how much of the previous season's ratings to carry over has been [adjusted to maximize the number of correctly-picked games, on average](#Define-Objective).

I do publish a separate "blank slate" model that does start fresh every season.  The 2025 "blank slate" ratings <a target="_blank" href="https://philthompson.me/nfl-elo/2025-only.html">are available here</a>.

<h3><a name="Elo-Exchanged-Appears-To-Not-Be-Net-Zero"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> Team A played Team B.  Team A appears to have gained more Elo rating points than Team B lost.  Shouldn't they be the same?</h3>

That is correct, and they are the same.  Team ratings and the rating points exchanged after games are decimal values behind the scenes.  They are only rounded for display on the website, which can make them appear to be different.

<h3><a name="Are-These-Biased-For-Team"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> Are these Elo ratings biased toward Team XYZ?  Or against Team XYZ?</h3>

No.  These Elo ratings are intended to be as [accurate](#Define-Accurate) and [objective](#Define-Objective) as possible.

<h3><a name="Where-Is-Discussion"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> Where can I see discussion of these ratings each week?</h3>

On <a target="_blank" href="https://old.reddit.com/user/ptdotme/submitted/?sort=new">reddit</a>.

<h3><a name="Why-Was-The-Model-Changed"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> Why was the model changed?</h3>

These Elo ratings are intended to be as [accurate](#Define-Accurate) and [objective](#Define-Objective) as possible.  Along those lines: if I find a more accurate model, I will switch to it.

As of 2024 and 2025, the models appear to have mostly plateaued, so I expect model updates to be annual (every offseason) at most.

Previous years' pages are still available as "frozen" pages.  See the top of <a target="_blank" href="https://philthompson.me/2025/NFL-Elo-Power-Rankings-for-2025.html">this post</a> for links to some old versions.

<h3><a name="Comment-Feedback-Suggestion"></a><small><a class="top-arw" title="Top" href="#top">↑</a></small> I have a comment, feedback, or suggestion.  How can I get in touch?</h3>

I look forward to getting feedback in weekly [reddit threads](#Where-Is-Discussion), and I can also be reached via <span>e</span>mail a<span>t</span> my first name at this do<span>m</span>ain.

<p></p>
<p></p>

<div class="btns">
	<a class="btn" href="./index.html">NFL Elo Home</a>
</div>