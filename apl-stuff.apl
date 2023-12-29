c ← ⎕CSV '/media/grenada/Data/Accounting/pk-crypto-tax-calculator/trading-data/coinbase-pro/fills-2023-12-22.csv'
5↑c[;5 2 4 7 11 6 8 10 ]

c ← ((⊂'exchange'),(¯1+≢c) ⍴ ⊂ 'coinbase-pro'),c

3↑d⍪⍨⍳2⌷⍴d

--------------------------------------------
COINBASE-PRO
(d h) ← ⎕CSV '/media/grenada/Data/Accounting/pk-crypto-tax-calculator/trading-data/coinbase-pro/fills-2023-12-22.csv' '' (1 1 1 1 1 2 1 2 2 2 1) 1 
### Check fee calculations
(|d[;10]) ≠(d[;6]×d[;8])+d[;9]×¯1+2×(⊂'BUY')≡¨d[;4]
hh ← 'time' 'exch' 'pair' 'id' 'side' 'base' 'quote' 'size' 'price' 'total' 'fee'
dcb← (19↑¨d[;5]),(⊂'coinbase-pro'),d[;3 2], d[;4 7 11 6],(|d[;10] ÷ d[;6]) ,↑|d[;10],¨d[;9]

--------------------------------------------
BINANCE

c← ⎕CSV '/media/grenada/Data/Accounting/pk-crypto-tax-calculator/trading-data/binance-2023-12-all/2020-2021.csv'
h←1↑c
d←1↓c
∪d[;12]

---Load all binance files at once
fd←(⊂'/media/grenada/Data/Accounting/pk-crypto-tax-calculator/trading-data/binance-2023-12-all/'),¨⊢'2020-2021' '2021-2022' '2022-2023' ,¨⊂'.csv'
d←(1↓⎕CSV fd[1])⍪(1↓⎕CSV fd[2])⍪(1↓⎕CSV fd[3])
h←(1↑⎕CSV fd[3])

-- remove canceled
df←(~d[;12]∊ ⊢'CANCELED' 'EXPIRED') /[1] d
---check status of selected
∪12 ⌷[2] df 

--- Extract base and quote
qb← 'BUSD' 'GBP' 'USD' 'USDT' 'BTC' 'ETH' 'DAI'
pp←df[;3]
+/1= ⌈/¨ ,/ p ∘.{⍸⍵⍷⍺} qb 
ps←⌈/¨ ,/ p ∘.{⍸⍵⍷⍺} qb
bq ← ↑↑p ,.{⊂((⍵-1)↑⍺) ((⍵-1)↓⍺)} ps 
b←bq[;1]
q←bq[;2]

--- remove chars from size and total
## a←df[;7]
##sz←⍎¨((df[;9]{⊃⍸⍵⍷⍺}¨b)-1)↑¨df[;9]
sz←⍎¨'^(\d+(\.\d+)?)([A-Z]+)$' ⎕S '\1' ⊢ df[;9]
b←'^(\d+(\.\d+)?)([A-Z]+)$' ⎕S '\3' ⊢ df[;9]
tot←⍎¨'^(\d+(\.\d+)?)([A-Z]+)$' ⎕S '\1' ⊢ df[;11]
q←'^(\d+(\.\d+)?)([A-Z]+)$' ⎕S '\3' ⊢ df[;11]

###tot←⍎¨((df[;11]{⊃⍸⍵⍷⍺}¨q)-1)↑¨df[;11]
--- check gibberish average price
###ap←⍎¨(~∨/¨(⊂'0E-') ⍷¨ df[;10]) /df[;10]
ap←⍎¨df[;10]
--- Check if size * average price == total
+/0.01<tot-¨sz×¨ap
dbn←(' ' ⎕R 'T' ⊢ df[;8]),(⊂'binance'),df[;3 2 5],b,q,sz,↑ap,¨tot,¨0

--Concat coinbase + binance
dd←dcb⍪dbn

-- Export csv file with all trades
dd hh (⎕CSV⍠'IfExists' 'Replace') 'all-trades.csv' 

⍝ --Load consolidated trades from csv

⍝ (d h) ← ⎕CSV 'all-trades.csv' '' ⍬ 1

⍝ ### ]display (,⍤⍕)¨(5↑d[;1])  {a←⊃⍺⋄w←⍵⋄{⍵[2]↑⍵[1]↓a}¨w }⍤ 0 1 ⊢ (↓6 2⍴0 4 5 2 8 2 11 2 14 2 17 2 21 2) 

⍝ -- Add number of days since 1899-12-21 as last column
⍝ dd←d, ¯1 1 ⎕DT ⊢ ⍎¨('-|T|:' ⎕R ',') ⊢ d[;1] ⍝ convert ISO datetime to days since 1899-12-31
⍝ d←dd
(≢d[;4])≠(≢∪d[;4]) ⍝ Check all order id's are unique

------------------------------------------
---  load klines and missing data stats

(d h) ← ⎕CSV './data-csv/BTC_USDT-1m.csv' '' (2 2 2 2 2 2) 1
x ← d[;1] ,[1.5]  4÷⍨ +/ d[;2 3 4 5] ⍝ calculate ohlc/4
-- Filling in missing values
t←x[;1] ⋄ td←(1↓t)-(¯1↓t)⋄10↑td ⍝ Timestamp diffs
{(⍺÷(1000×60×60)) (≢⍵)}⌸td ⍝ Time diffs in hours
ix←⍸ td ≠ 60000 ⋄ix ⍝ indexes of missing data
av←2÷⍨d[ix;2] + d[ix+1;2]⋄10↑av ⍝ average of left and right sides
m←¯1+60000÷⍨d[ix+1;1]-d[ix;1]⋄xx←x⍪ ↑↑,/(d[ix;1]+60000×⍳¨m),¨¨av⋄sx←xx[⍋xx[;1];]⋄10↑sx ⍝ Insert missing values and sort
{(⍺÷(1000×60×60)) (≢⍵)}⌸ ⊢ {(1↓⍵[;1])-(¯1↓⍵[;1])} sx ⍝ Check now all dime diffs are the same

--------------------------------------------
⍝ -- Function for filling missing data

]dinput 
fill_missing ← {  ⍝ Fill missing rows with average of both sides
    ix←⍸ ((1↓⍵[;1])-(¯1↓⍵[;1])) ≠ 60000 ⍝ indexes of missing data
    av←2÷⍨⍵[ix;2] + ⍵[ix+1;2] ⍝ average of left and right sides
    m←¯1+60000÷⍨⍵[ix+1;1]-⍵[ix;1]
    xx←⍵⍪ ↑↑,/(⍵[ix;1]+60000×⍳¨m),¨¨av
    xx[⍋xx[;1];] ⍝ Insert missing values and sort
}

⍝ -------------------------------------------
⍝ -- function for loading candle csvs
cload ← { (d h) ← ⎕CSV ⍵ '' (2 2 2 2 2 2) 1 ⋄ d}
side_inv←{('SELL' 'BUY')[1+⍵ ∊⊂'SELL']}⍝ function to invert BUY/SELL to +1/-1
⍝ ---  load BTC/USDT and ETH/USDT and fill missing values

⍝ 10 ↑ fbtc← fill_missing {⍵[;1] ,[1.5]  4÷⍨ +/ ⍵[;2 3 4 5]} cload './data-csv/BTC_USDT-1m.csv'
⍝ 10 ↑ feth← fill_missing {⍵[;1] ,[1.5]  4÷⍨ +/ ⍵[;2 3 4 5]} cload './data-csv/ETH_USDT-1m.csv'
⍝ 10 ↑ fgbp← fill_missing {⍵[;1] ,[1.5]  4÷⍨ +/ ⍵[;2 3 4 5]} cload './data-csv/GBP_USDT-1m.csv'

⍝ -------------------------------------------
⍝ --- Load quote klines
qhi←'BTC' 'ETH' 'GBP'
dhi←⌷fill_missing¨{⍵[;1] ,[1.5]  4÷⍨ +/ ⍵[;2 3 4 5]}¨{cload⊢'./data-csv/',⍵,'_USDT-1m.csv' }¨qhi

⍝ -------------------------------------------
⍝ --- Load trade data

(d h)←(2 1){¯1↓[⍺]⍵}¨ ⎕CSV 'all-trades.csv' '' (1 1 1 1 1 1 1 2 2 2 2) 1 ⍝ load trades and drop last column
h←(⊂'ts'), h ⍝ add ts as first column
d←(¯1 12⎕DT 0,⍨¨5↑¨ ⍎¨('-|T|:' ⎕R ',') ⊢ d[;1]) , d ⍝ add unix timestamp as first column
d[;8]← {⊂'USDT'} @{⍵ ∊ 'DAI' 'USDC' 'BUSD'} ⊢ d[;8] ⍝ replace DAI USDC BUSD with USDT

⍝ --- split by quote
(qtd dtd)←↓⍉d[;8]{⍺, ⊂⍵}⌸d ⍝ extract transaction groups and rows by quote 
⍝ --- quote currencies to be converted
qconv←'ETH' 'BTC'
dconv←dtd[qtd ⍳ qconv] ⍝ 
⍝ ---historical prices for qconv/dconv
dcohi←dhi[qhi ⍳ qconv]
dconQP←dconv {⍵[⍵[;1] ⍳ ⍺[;1];2]}¨ dcohi ⍝ extract historical prices
dconPU← dconQP {⍵[;10] × ⍺}¨ dconv ⍝ Prices of base in USDT
dconFo←dconPU {(⍵[;9]×⍺),⍨⍺,⍨⍵[;6 9],⍨⍵[;1 7],⊂'F'}¨ dconv ⍝ Forward-converted to USDT
dconBa← dconQP {(⍺×⍵[;11]),⍨⍺,⍨⍵[;,11],⍨(side_inv ⍵[;,6]),⍨⍵[;1 8],⊂'B'}¨ dconv ⍝ Forward-converted to USDT

        3↑¨ dconPU {⍺,⍨⍵[;,8 11],⍨⍵[;,1],side_inv ⍵[;,6]}¨ dconv ⍝ Forward-converted to USDT
 (⍳≢h),[0.5]h
⍝ -- quote prices
qpr←¨qt{bq←⊃qk[q⍳⊂⍺]⋄{⍵}@(bq[;1] ⍳ ⍵)⊢bq[;2]}¨ {⍵[;1]}¨(dd[;1]∊qt) / dd[;2]

{(q t)←↓⍉⍵⋄⎕←q}(dd[;1] ∊ 'ETH' 'BTC') ⌿ dd

⍝ 10↑(,∘'00')¨(¯2↓¨d[;2]) ⍝ replace seconds with '00'
⍝ (d h) ← ⎕CSV './data-csv/BTC_USDT-1m.csv' '' (2 2 2 2 2 2) 1
⍝ x ← d[;1] ,[1.5]  4÷⍨ +/ d[;2 3 4 5] ⍝ calculate ohlc/4
⍝ (deu heu) ← ⎕CSV './data-csv/ETH_USDT-1m.csv' '' (2 2 2 2 2 2) 1
⍝ (dgu hgu) ← ⎕CSV './data-csv/GBP_USDT-1m.csv' '' (2 2 2 2 2 2) 1
⍝ )copy dfns days
⍝ ]display 10↑ 0,⍨¨5↑¨ ⍎¨('-|T|:' ⎕R ',') ⊢ d[;1]
⍝ ]display 10↑ ¯1 12⎕DT 0,⍨¨5↑¨ ⍎¨('-|T|:' ⎕R ',') ⊢ d[;1]  
⍝ dux← ¯1 12⎕DT 0,⍨¨5↑¨ ⍎¨('-|T|:' ⎕R ',') ⊢ d[;1] ⍝ get Convert to UNIX timestamp

⍝ x←{(⊃⍺)(≢⍵)}⌸ d[;8]⋄x[(⍒x[;2]);] ⍝ Number of transactions per quote currency
⍝ x←{(⊃⍺)(≢⍵)}⌸ d[;7]⋄x[(⍒x[;2]);] ⍝ Number of transactions per base currency
⍝ {⍺ (≢⍵)}⌸⊢d[;8] ⍝ Number of trades per quote

⍝ x←(d[;8] ∊ 'BTC' 'ETH') /[1] d⋄¯1↓[2] 10↑ ¯1↓(⍳≢h)⍪h⍪x ⍝ Drop last columns and add headers/column numbers

⍝ ---Generate additional transactions for quotes in BTC ETH GBP
x←(d[;8] ∊ 'BTC' 'ETH' 'GBP') /[1] d⋄x[;7 9 6]←x[;8 11],('SELL' 'BUY')[1+x[;6] ∊⊂'SELL']⋄x[;10 11]←0⋄x[;8]← ⊂'USDT'

⍝ --Fill in BTC and ETH prices
fd←fbtc⋄bx←(x[;7] ≡¨ ⊂'BTC')⋄tsx←bx/x[;1]⋄fix←fd[;1] ⍳ tsx⋄x[;10]←(fd[;2][fix])@(⍸bx)⊢x[;10]
fd←feth⋄bx←(x[;7] ≡¨ ⊂'ETH')⋄tsx←bx/x[;1]⋄fix←fd[;1] ⍳ tsx⋄x[;10]←(fd[;2][fix])@(⍸bx)⊢x[;10]
fd←fgbp⋄bx←(x[;7] ≡¨ ⊂'GBP')⋄tsx←bx/x[;1]⋄fix←fd[;1] ⍳ tsx⋄x[;10]←(fd[;2][fix])@(⍸bx)⊢x[;10]
+/x[;10]=0 ⍝ check if any prices are empty
x[;11]←×/[2]x[;9 10] ⍝ calculate total
+/x[;11]=0 ⍝ check if any totals are empty

dd←{⍵[⍋⍵[;1];]}d⍪x ⍝ append supplementary transactions
------------------------------------------
---  Main calculations
------------------------------------------