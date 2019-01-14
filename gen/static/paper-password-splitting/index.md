
# Paper Password Splitting

Below you'll find resources for splitting passwords on paper, and for recovering split passwords.

For background information, see [this blog article](${SITE_ROOT_REL}/2019/Paper-Password-Splitting.html).

Please perform password recovery with pen and paper, using a battery-powered calculator if needed.

## Recovery

1. **Find a pair of recovery phrases**
 
 To recover a split password, you'll need a matching pair of recovery phrases.  If they're labeled according to the above article, a matching pair of recovery phrases will be labeled like **"A1"** and **"A2"**, or **"B1"** and **"B2"**, or similar.

1. **Find the wordlist**

 Once you've obtained a matching pair of recovery phrases, you'll need the "wordlist" originally used to create the recovery phrases.  If the recovery phrases are written on a [recovery sheet](./Recovery-Sheet.pdf) the location of the wordlist should be listed.

 Commonly-used wordlists are linked below.

 If the recovery phrases are regular passwords, not multiple-word phrases, you'll be using a list of ASCII characters (letters/numbers/symbols) instead of a wordlist, but it recovery works the same way.

1. **Perform recovery**

 Grab a piece of paper, a pen, and perhaps a battery-powered calculator.

 The recovery itself is done with "modular addition" of each Nth word in both recovery phrases.

 1. ADD the numeric values of the 1st word of both recovery phrases (numeric values found in the wordlist).
   If the sum is larger than the number of words in the wordlist, SUBTRACT the number of words in the wordlist.
   Write down the final numeric value for the 1st word, then find the word in the wordlist with that numeric value.  That's the 1st word of the secret password.

 1. ADD the numeric values of the 2nd word of both recovery phrases (numeric values found in the wordlist).
   If the sum is larger than the number of words in the wordlist, SUBTRACT the number of words in the wordlist.
   Write down the final numeric value for the 2nd word, then find the word in the wordlist with that numeric value.  That's the 2nd word of the secret password.

 1. And so on with the 3rd, 4th, etc., words in the recovery phrases.

 1. You now have recovered all the words of the original secret password.

Example recovery using 7,776-word wordlist:

<style>
    table#example-recovery { border-collapse: collapse; border: 1px solid #829191; }
    table#example-recovery td { padding: 0.6rem; text-align: center; }
    table#example-recovery td.underline { border-bottom: 1px solid gray; }
</style>

<table id="example-recovery">
  <tr>
  	<td>recovery phrase</td><td>justify<br/>3540</td><td>routine<br/>5557</td><td>banana<br/>485</td><td>suffix<br/>6573</td><td>monotype<br/>3983</td><td>exfoliate<br/>2419</td><td></td>
  </tr>
  <tr>
  	<td>recovery phrase</td><td>boss<br/>647</td><td>hamburger<br/>3086</td><td>bronchial<br/>709</td><td>reset<br/>5382</td><td>virtuous<br/>7554</td><td>cut<br/>1525</td><td></td>
  </tr>
  <tr style="line-height: 0.1rem;">
  	<td></td><td class="underline" style="text-align:left;">+</td><td class="underline"></td><td class="underline"></td><td class="underline"></td><td class="underline"></td><td class="underline"></td><td></td>
  </tr>
  <tr>
  	<td>mod 7776</td><td>4187<br/>&nbsp;</td><td>&nbsp;&nbsp;8643<br/><u>-&nbsp;7776</u></td><td>1194<br/>&nbsp;</td><td>&nbsp;11955<br/><u>-&nbsp;7776</u></td><td>&nbsp;11537<br/><u>-&nbsp;7776</u></td><td>3944<br/>&nbsp;</td><td></td>
  </tr>
  <tr>
  	<td>secret phrase</td><td>4187<br/>nurture</td><td>867<br/>cardiac</td><td>1194<br/>commence</td><td>4179<br/>numeral</td><td>3761<br/>luckless</td><td>3944<br/>mobilize</td><td></td>
  </tr>
</table>



For another example, the ["2-of-2 splitting section in the blog article](${SITE_ROOT_REL}/2019/Paper-Password-Splitting.html#split-2-of-2) shows how a passphrase can be split into two recovery phrases and then recovered.

## Wordlists

The wordlists below all have number columns for use with paper password splitting.

For password recovery, you can ignore the columns with dice values.

### Diceware ###
**[philthompson.me Customized EFF Wordlist 2019](https://github.com/philthompson/eff_diceware/blob/master/eff_large_wordlist-2019.txt)** &mdash; 2019 version of a 5-die 7,776-word English wordlist, based on the EFF's long wordlist

### BIP-39 ###
**[BIP39 English](./BIP-0039-english-dice.txt)** &mdash; 2,048 English words standardized for [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) crypto currency mnemonic wallet seeds

### ASCII ###
**[philthompson.me ASCII](./ASCII-philthompson.me.txt)** &mdash; Custom ordering of the ASCII character set to easily find character values from 1-95

**[ASCII Decimal Values Minus 31](./ASCII-Decimal-Values-Minus-31.txt)** &mdash; Standard ASCII character set, where each true ASCII decimal value is less 31 to create numbered characters from 1-95

<hr/>

*Diceware&trade; is a trademark of Arnold G. Reinhold, and for more information you can visit [his Diceware page](http://world.std.com/~reinhold/diceware.html).*
