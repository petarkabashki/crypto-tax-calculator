⍝ --- Quote currencies
qb← 'USDC' 'BUSD' 'GBP' 'USDT' 'BTC' 'ETH' 'DAI'

⍝ --------------------------------------------
⍝ COINBASE-PRO
(d h) ← ⎕CSV 'trading-data/coinbase-pro/fills-2023-12-22.csv' '' (1 1 1 1 1 2 1 2 0 2 1) 1 
(⍳≢h),[0.5]h ⍝ header
+/0.0001<(d[;9])-¨×/d[;6 8] ⍝ Check if price × size = total

hh ← 'time' 'exch' 'pair' 'id' 'side' 'base' 'quote' 'size' 'price' 'total'
⍴3↑dcb←(('T'⎕R ' ')¨19↑¨ d[;5]),(⊂'coinbase-pro'),(('-'⎕R '')¨d[;3]),d[;2], d[;4 7 10 6 8],×/d[;6 8]

⍝ --------------------------------------------
⍝ PHEMEX
(d h)  ← ⎕CSV 'trading-data/phemex/SPOT_TRADE_2023.csv' '' ⍬ 1
(⍳≢h),[0.5]h ⍝ header
d[;3]←('SELL' 'BUY')[1+(≡∘'Buy')¨d[;3]] ⍝ Massage Buy/Sell
∪ q←{qb[⍵]}⍸¨↓d[;2]∘.{⍵≡(-≢⍵)↑⍺} qb ⍝ Extract quote
∪ b←q{(-3+≢⍺)↓⍵}¨d[;2] ⍝ Extract base
szt←↑(d[;3]≡¨⊂'SELL') {⍺⌽⍵}¨ ↓d[;4 6] ⍝ Get size and total as columns
sz←⍎¨ b{(-≢⍺)↓⍵}¨szt[;1] ⍝ extract size
tot←⍎¨ q{(-≢⍺)↓⍵}¨szt[;2] ⍝ extract total
3↑dphm←d[;1],(⊂'phemex'),(b,¨q),d[;12 3],b,q,sz,(tot÷sz),⍉(1,≢tot)⍴tot 

⍝ --------------------------------------------
⍝ BITGET

(d h)  ← ⎕CSV 'trading-data/bitget/Spot Order History-2023.csv' '' (1 1 1 1 2 2 2 1 1 0) 1 
d[;8]←⍎¨(⊂'0.0')@{(''∘≡)¨⍵}⊢ d[;8] ⍝ Replace empty values with '0' and convert to numbers
d←d⌿⍨~(≡∘'cancelled')¨ d[;9] ⍝ remove canceled
p←¯5↓¨d[;3] ⍝ extract pairs
⍝ --- Extract base and quote
10↑ q←{qb[⍵]}⍸¨↓p∘.{⍵≡(-≢⍵)↑⍺} qb ⍝ Extract quote currencies
10↑ b←q{(-≢⍺)↓⍵}¨p ⍝ Extract base currencies
d[;4]←('SELL' 'BUY')[1+(≡∘'Buy')¨d[;4]] ⍝ Massage Buy/Sell
⍝ d←⍕d ⍝ convert numerics
dbtg←d[;1],(⊂'phemex'),p,'-',d[;4],b,q,d[;7 8],×/d[;7 8]

⍝ --------------------------------------------
⍝ BINANCE
⍝ ---Load all binance files at once
fd←(⊂'trading-data/binance/OrderHistory/'),¨ ('2020-with-time' '2021' '2022' '2023') ,¨⊂'.csv'
d← ⊃⍪/{⊃1↑⎕CSV ⍵ '' ⍬ 1}¨ fd ⍝ load data from csvs
d←(~d[;12]∊ ⊢'CANCELED' 'EXPIRED') /[1] d ⍝ -- remove canceled

⍝ --- Extract base and quote
10↑ q←{qb[⍵]}⍸¨↓d[;3]∘.{⍵≡(-≢⍵)↑⍺} qb ⍝ Extract quote currencies
10↑ b←q{(-≢⍺)↓⍵}¨d[;3] ⍝ Extract base currencies

d[;9]←⍎¨ d[;9] {(-≢⍵)↓⍺}¨ b ⍝ extract base
d[;11]←⍎¨d[;11] {(-≢⍵)↓⍺}¨ q ⍝ extract quote

10↑d[;10]←⍎¨ { 'E-' ⎕R 'E¯' ⊢⍵}¨ d[;10] ⍝ massage price and convert to number
⍝ --- Check if size * average price == total
+/0.001<|d[;11]-×/d[;9 10] ⍝ check if price × size = total
3↑ dbn←d[;1],(⊂'binance'),d[;3 2 5],b,q,d[;9 10 11]

⍝ ----------------------------------------
⍝ --Concat orders from all exchanges
dd←dcb⍪dbn⍪dbtg⍪dphm
⍝ -- Export csv file with all trades
dd hh (⎕CSV⍠'IfExists' 'Replace') 'all-trades.csv' 
⍝ ----------------------------------------


⍝ --Load consolidated trades from csv

(d h) ← ⎕CSV 'all-trades.csv' '' ⍬ 1

⍝ ### ]display (,⍤⍕)¨(5↑d[;1])  {a←⊃⍺⋄w←⍵⋄{⍵[2]↑⍵[1]↓a}¨w }⍤ 0 1 ⊢ (↓6 2⍴0 4 5 2 8 2 11 2 14 2 17 2 21 2) 

⍝ -- Add number of days since 1899-12-21 as last column
⍝ dd←d, ¯1 1 ⎕DT ⊢ ⍎¨('-|T|:' ⎕R ',') ⊢ d[;1] ⍝ convert ISO datetime to days since 1899-12-31
⍝ d←dd
⍝ (≢d[;4])≠(≢∪d[;4]) ⍝ Check all order id's are unique

⍝ ------------------------------------------
⍝ ---  load klines and missing data stats

⍝ (d h) ← ⎕CSV './data-csv/BTC_USDT-1m.csv' '' (2 2 2 2 2 2) 1
⍝ x ← d[;1] ,[1.5]  4÷⍨ +/ d[;2 3 4 5] ⍝ calculate ohlc/4
⍝ ⍝ -- Filling in missing values
⍝ t←x[;1] ⋄ td←(1↓t)-(¯1↓t)⋄10↑td ⍝ Timestamp diffs
⍝ {(⍺÷(1000×60×60)) (≢⍵)}⌸td ⍝ Time diffs in hours
⍝ ix←⍸ td ≠ 60000 ⋄ix ⍝ indexes of missing data
⍝ av←2÷⍨d[ix;2] + d[ix+1;2]⋄10↑av ⍝ average of left and right sides
⍝ m←¯1+60000÷⍨d[ix+1;1]-d[ix;1]⋄xx←x⍪ ↑↑,/(d[ix;1]+60000×⍳¨m),¨¨av⋄sx←xx[⍋xx[;1];]⋄10↑sx ⍝ Insert missing values and sort
⍝ {(⍺÷(1000×60×60)) (≢⍵)}⌸ ⊢ {(1↓⍵[;1])-(¯1↓⍵[;1])} sx ⍝ Check now all dime diffs are the same

⍝ --------------------------------------------
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
⍝ -- function for loading candle csvs
cload ← { (d h) ← ⎕CSV ⍵ '' (2 2 2 2 2 2) 1 ⋄ d}
side_inv←{('SELL' 'BUY')[1+⍵ ∊⊂'SELL']}⍝ function to invert BUY/SELL to +1/-1
⍝ ---  load BTC/USDT and ETH/USDT and fill missing values

⍝ -------------------------------------------
⍝ --- Load trade data

(d h)← ⎕CSV 'all-trades.csv' '' (1 1 1 1 1 1 1 2 2 2) 1 ⍝ load trades 
h←(⊂'ts'), h ⍝ add ts as first column
d←(¯1 12⎕DT 0,⍨¨5↑¨ ⍎¨('-|T|:' ⎕R ',') ⊢ d[;1]) , d ⍝ add unix timestamp as first column
d[;8]← {⊂'USDT'} @{⍵ ∊ 'DAI' 'USDC' 'BUSD'} ⊢ d[;8] ⍝ replace DAI USDC BUSD with USDT
d←d[⍋d[;1];] ⍝ Sort by timestamp

⍝ --- split by quote
(qtd dtd)←↓⍉d[;8]{⍺, ⊂⍵}⌸d ⍝ extract transaction groups and rows by quote 
⍝ --- quote currencies to be converted
qconv←'ETH' 'BTC' 'GBP' 
dconv←dtd[qtd ⍳ qconv] ⍝ transactions to be converted, in order of qconv
⍝ ---historical prices for qconv/dconv
dcohi←dhi[qhi ⍳ qconv] ⍝ historical quote prices in order of qconv
dconQP←dconv {⍵[⍵[;1] ⍳ ⍺[;1];2]}¨ dcohi ⍝ extract historical prices
dconPU← dconQP {⍵[;10] × ⍺}¨ dconv ⍝ Prices of base in USDT
dconFo←dconPU {(⍵[;9]×⍺),⍨⍺,⍨⍵[;5 6 9],⍨⍵[;1 2 3 7],⊂'F'}¨ dconv ⍝ Forward-converted to USDT
dconBa← dconQP {(⍺×⍵[;11]),⍨⍺,⍨⍵[;,11],⍨(⍵[;5], side_inv ⍵[;,6]),⍨⍵[;1 2 3 8],⊂'B'}¨ dconv ⍝ Forward-converted to USDT
⍝ --- transactions in USDT
dusdt← {⍵[;5 6 9 10 11],⍨⍵[;1 2 3 7],⊂'N'}¨ dtd[qtd ⍳ ⊂'USDT']
⍝ --- ALL TRANSACTIONS - converted + inverted + normal(usdt)
htr←'ts' 'time' 'xchg' 'asset' 'type' 'id' 'side' 'size' 'price' 'total'
10↑tr← {w←⍵⋄w[;8 10]×←w[;7 7]⋄w} {w←⍵⋄w[;7]←¯1+2×⍵[;7]≡¨⊂'BUY'⋄w} {⍵[⍋⍵[;1];]}⊃⍪/dconFo,dconBa,dusdt
⍝ 10↑ tr[;6]←¯1+2×tr[;6]≡¨⊂'BUY' ⍝ Convert BUY/SELL to +1/-1
(⍳≢h),[0.5]h

⍝ {w←⍵⋄w[;7 9]×←w[;6 6]⋄w}

⍝ -------------------------------------------
⍝ --- Calculations and Reports

(qtr dtr)←↓⍉tr[;4]{⍺, ⊂⍵}⌸tr ⍝ extract transaction groups and rows by asset 
dtr←{⍵[⍋⍵[;1],-⍵[;,7];]}¨ dtr ⍝ Sort by timestampm then buys first
qtr,[0.5]≢¨dtr ⍝ Number of transactions per asset
qtr,[0.5]{∨/(⍳≢⍵[;1])≠⍋⍵[;1]}¨ dtr ⍝ check for unsorted asset transacttion groups

⍝ 5↑xtr←⊃dtr[4] ⍝ extract a transaction for XRP
⍝ {⍺ ⍵} / ⌽ 'a',  ⍳3 ⍝ example running calculation


⍝ {ns←⍺[1]+⍵[1]⋄nt←⍺[3]+⍵[3]⋄0,ns,(nt÷ns),nt}/⌽↓(4⍴0)⍪ 3↑ ¯4↑[2] xtr

⍝ {ns←⍺[1]+⍵[1]⋄nt←⍺[3]+⍵[3]⋄0,ns,(nt÷ns),nt}↓⊖{(⍵[;1]×⍵[;2]),⍵[;,3],⍵[;1]×⍵[;4]} (4⍴0)⍪ 6↓ 8↑ ¯4↑[2] xtr
⍝ --- calculates the final bag after transactions
HorMat ← {(¯2↑1,⍴⍵)⍴⍵}
⍝ --- function to apply side +1/-1 to size and total, leaving only columns (+-)size,price,(+-)total
ApplySide ← {(⍵[;1]×⍵[;2]),⍵[;,3],⍵[;1]×⍵[;4]}
⍝ --- Calculates rolling holding bag for asset
⍝ ]display ⊖⊃{w←HorMat ⍵⋄p←{⍵[1]>0:⍵[2]⋄⍵[3]}⍺[1],⍺[2],w[1;2]⋄ns←⍺[1]+w[1;1]⋄nt←w[1;3]+⍺[1]×p⋄(ns,(nt{⍵=0:0⋄⍺÷⍵}ns),nt)⍪w} /↓⊖ {⍵[;2 3 4]} 0⍪ 8↑ ¯4↑[2] xtr

⍝ --- Function that Calculates Rolling Bag for asset
RollingBag ← {1↓⊖⊃{w←HorMat ⍵⋄p←{⍵[1]>0:⍵[2]⋄⍵[3]}⍺[1],⍺[2],w[1;2]⋄ns←⍺[1]+w[1;1]⋄nt←w[1;3]+⍺[1]×p⋄(ns,(nt{⍵=0:0⋄⍺÷⍵}ns),nt)⍪w} /↓⊖ 0⍪ ⍵}

⍝ 10↑¨ 4⌷ ⊢{1↓⊖⊃{w←HorMat ⍵⋄p←{⍵[1]>0:⍵[2]⋄⍵[3]}⍺[1],⍺[2],w[1;2]⋄ns←⍺[1]+w[1;1]⋄nt←w[1;3]+⍺[1]×p⋄(ns,(nt{⍵=0:0⋄⍺÷⍵}ns),nt)⍪w} /↓⊖ 0⍪ ⍵}¨  {¯3↑[2]⍵}¨ dtr
10↑¨ 4⌷ rbags←{⍵,+⍀¯1↑[2]⍵}¨ {1↓⊖⊃{w←HorMat ⍵⋄p←{⍵[1]>0:⍵[2]⋄⍵[3]}⍺[1],⍺[2],w[1;2]⋄ns←⍺[1]+w[1;1]⋄nt←w[1;3]+⍺[1]×p⋄pnl←⍺{⍺[1]>0:0⋄⍺[1]×⍵[2]-⍺[2]}w[1;]⋄(ns,(nt{⍵=0:0⋄⍺÷⍵}ns),nt,pnl)⍪w} /↓⊖ ⊢0⍪ ⍵}¨ 0,⍨¨ {¯3↑[2]⍵}¨ dtr

⍝ ]dinput 
⍝ RollingBag ← {
⍝     1↓⊖⊃{
⍝             w←HorMat ⍵
⍝             p←{
⍝                 ⍵[1]>0:⍵[2]⋄⍵[3]
⍝             } ⍺[1],⍺[2],w[1;2]
⍝             ns←⍺[1]+w[1;1]
⍝             nt←w[1;3]+⍺[1]×p
⍝             pnl←⍵[1]>0:0⋄(⍺[2]-w[1;2])×⍺[1]
⍝             (ns,(nt{⍵=0:0⋄⍺÷⍵}ns),nt,pnl)⍪w
⍝     } /↓⊖ 0⍪ ⍵
⍝ }

⍝ --- Calculate rolling bags 
hbags ← 'bsize' 'bprice' 'btotal' 'pnl'
⍝ rbags←RollingBag¨ {¯3↑[2]⍵}¨ dtr
⍝ pnls← dtr{m←⍺[;6]=-1⋄m×(⍺[;7]-⍵[;2])×⍵[;1]}¨ rbags ⍝ Calculate PNLs

⍝ ⎕←qtr,⊃⍪/(¯1↑¨rbags) ⍝ bags after all transactions 

lbags←{⍵[⍋⍵[;1];]} qtr,{⍵[;1],(⍵[;3]÷⍵[;1]),⍵[;,3]}⊃⍪/(¯1↑¨rbags) ⍝ Latest bags with average price
lbags ('asset' 'size' 'avgPrice' 'totalUSDT') (⎕CSV⍠'IfExists' 'Replace') 'latest-bags.csv' 
⍝ --- Export transactions and rolling bags
( (⊃dtr[1]),(⊃rbags[1]) ) (htr, hbags) (⎕CSV⍠'IfExists' 'Replace') 'tran-bags.csv' 
⍝ --- Function to export transactions for asset like: fxtr 'BNB'
⍝ fxtr←{(⊃dtr[qtr⍳(⊂⍵)]) htr (⎕CSV⍠'IfExists' 'Replace') ('reports/transactions/',⍵,'-transactions.csv')}
⍝ fxrbg←{(⊃rbags[qtr⍳(⊂⍵)]) hbags (⎕CSV⍠'IfExists' 'Replace') ('reports/rolling-bags/',⍵,'-rolling-bag.csv')}
⍝ fxtrbg←{⊃dtr{⍺,⍵}¨rbags {⍺,⍵}¨ pnls) (htr,hbags,⊂'pnl') (⎕CSV⍠'IfExists' 'Replace') ('reports/tran-bags/',⍵,'-tran-bag.csv'}
⍝ Concatenate transactions, bags, pnl
⍴¨trbnls←{⍵,+⍀¯1↑[2]⍵}¨ dtr{⍺,⍵}¨ ⊢ {¯1↓[2]⍵}¨ rbags 
hpnltr←htr,hbags,⊂'cumpnl'
⍝ fxtr←{(⊃trbnls[qtr⍳(⊂⍵)]) hpnltr) (⎕CSV⍠'IfExists' 'Replace') ('reports/transactions/',⍵,'.csv')}

csvr←{⍺ (⎕CSV⍠'IfExists' 'Replace') ⍵} ⍝ CSV with file replace 

⍝ --- Export BAGS and transactions per asset
⍝ fxtr¨qtr ⍝ transactions
⍝ fxrbg¨qtr ⍝ bags
⍝ fxtrbg¨qtr ⍝ combined transactions+bags
xqs ← 'GBP' 'USDC' 'USDT' 'BUSD' ⍝ Excluded from pnl
pntrs←{⍵,+⍀¯1↑[2]⍵} {⍵[⍋⍵[;1 4];]} ⊃,[1]/ (~qtr ∊ xqs) / trbnls ⍝ all transacttions with bags and pnl
pntrs hpnltr csvr 'pnl-transactions.csv'

⍝ --- Calculate PNLs 

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

⍝ ------------------------------------------
⍝ --- Bed & Breakfast rule

10↑x← {⍵[;1],¯4↑[2]⍵} ⊃dtr[1]
]display 10↑ 30↓ (3↑¨12 ¯1⎕DT 1↑[2] x),(⌊12 1⎕DT 1↑[2] x),x
(⌊12 1∘⎕DT) ,/ ⊢ 10↑ 40↓ x[;,1]
]display x←10×⍳10⋄↑{⍵,⊂⍸ (x≥⍵)∧x≤⍵+30}¨x

]display {x←⍵⋄{⍵, ⊂⍸ (x≥⍵)∧x≤⍵+30}¨⍵} ⊢ ⌊12 1⎕DT 10↑ ,1↑[2] ⊃dtr[1]
⍝ -
]display tr←20↑ 30↓⊃dtr[1]
]display d←⌊12 1⎕DT tr[;1] 
]display  ix30←{⊂⍸ (d≥⍵)∧d≤⍵+30}¨d  
]display  ⍴¨{⍵[;7]}¨{(tr[⊃⍵;7]=1)/[1]tr[⊃⍵;]}¨ {⊂⍸ (d≥⍵)∧d≤⍵+30}¨d  
]display   ¯4↑[2]¨ {(tr[⊃⍵;7]=1)/[1]tr[⊃⍵;]}¨ {⊂⍸ (d≥⍵)∧d≤⍵+30}¨d  
]display ≢¨{⍸(d≥⍵)∧d≤⍵+30}¨ d×tr[;7]=¯1  
]display ¯4↑[2]¨ {(tr[⍵;7]=1)/[1]tr[⍵;]}¨ {⍸(d≥⍵)∧d≤⍵+30}¨ d×tr[;7]=¯1  

⍝ --- collect a list of next 30 days buys for every sell
lbuys←¯4↑[2]¨ {(tr[⍵;7]=1)/[1]tr[⍵;]}¨ {⍸(d≥⍵)∧d≤⍵+30}¨ d×tr[;7]=¯1 ⍝ buys in nextt 30 days for every sell  

⍝ -------------------------------------------


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