# inter_canister
terminal 1
```bash
cd inter_canister/
# 启动 ic 本地环境
dfx start --clean
```

terminal 2
```bash
$ cd inter_canister/

$ dfx canister create --all
Creating canister "swap"...
Creating the canister using the wallet canister...
Creating a wallet canister on the local network.
The wallet canister on the "local" network for user "default" is "rwlgt-iiaaa-aaaaa-aaaaa-cai"
"swap" canister created with canister id: "rrkah-fqaaa-aaaaa-aaaaq-cai"
Creating canister "token1"...
Creating the canister using the wallet canister...
"token1" canister created with canister id: "ryjl3-tyaaa-aaaaa-aaaba-cai"
Creating canister "token2"...
Creating the canister using the wallet canister...
"token2" canister created with canister id: "r7inp-6aaaa-aaaaa-aaabq-cai"


$ dfx build --all
Building canisters...


$ dfx canister install --all
Installing code for canister swap, with canister_id rrkah-fqaaa-aaaaa-aaaaq-cai
Installing code for canister token1, with canister_id ryjl3-tyaaa-aaaaa-aaaba-cai
Installing code for canister token2, with canister_id r7inp-6aaaa-aaaaa-aaabq-cai



# 初始化 Token1，Alice 有 1000 个 Token1
$ dfx --identity alice_auth canister call token1 init '("Token0", "T0", 0, 1000)'
(true)

$ Alice="principal \"$(dfx --identity alice_auth identity get-principal | sed 's/[\\(\\)]//g')\""

$ echo $Alice
principal "bx3v7-ogsy2-p64w7-ra77s-il633-ixu5y-ons34-vhghi-kruft-b6o6t-dqe"

$ dfx canister call token1 balanceOf "($Alice)"
(1_000)



# 初始化 Token2，Bob 有 1000 个 Token2
$ dfx --identity bob_standard canister call token2 init '("Token2", "T2", 0, 1000)'
(true)

$ Bob="principal \"$(dfx --identity bob_standard identity get-principal | sed 's/[\\(\\)]//g')\""

$ echo $Bob
principal "pc5d2-fhhon-5geo3-euvhw-hokpr-v2ng5-axewa-wox77-fxpqq-n6ffy-5qe"

$ dfx canister call token2 balanceOf "($Bob)"
(1_000)



# 从前面的输出拿到 Token1 和 Token2 和 Swap 的地址
$ Token1='principal "ryjl3-tyaaa-aaaaa-aaaba-cai"'

$ echo $Token1
principal "ryjl3-tyaaa-aaaaa-aaaba-cai"

$ Token2='principal "r7inp-6aaaa-aaaaa-aaabq-cai"'

$ echo $Token2
principal "r7inp-6aaaa-aaaaa-aaabq-cai"

$ Swap='principal "rrkah-fqaaa-aaaaa-aaaaq-cai"'

$ echo $Swap
principal "rrkah-fqaaa-aaaaa-aaaaq-cai"


# Alice 使用 100 个 Token1 兑换 300 个 Token2
$ dfx --identity alice_auth canister call swap pending "($Token1, 100, $Token2, 300)"
(true)

$ dfx canister call swap getOrder "($Alice)"
(
  opt record {
    to_token = principal "r7inp-6aaaa-aaaaa-aaabq-cai";
    from_amount = 100;
    from_token = principal "ryjl3-tyaaa-aaaaa-aaaba-cai";
    owner = principal "bx3v7-ogsy2-p64w7-ra77s-il633-ixu5y-ons34-vhghi-kruft-b6o6t-dqe";
    to_amount = 300;
  },
)

$ dfx --identity alice_auth canister call token1 approve "($Swap, 100)"
(true)



# Bob 同意了这笔订单，即使用 300 个 Token2 兑换 100 个 Token1
$ dfx --identity bob_standard canister call token2 approve "($Swap, 300)"
(true)



# 查看各自的余额
$ dfx canister call token1 balanceOf "($Alice)"
(1_000)

$ dfx canister call token1 balanceOf "($Bob)"
(0)

$ dfx canister call token2 balanceOf "($Alice)"
(0)

$ dfx canister call token2 balanceOf "($Bob)"
(1_000)



# 成交
$ dfx --identity bob_standard canister call swap deal "($Alice)"
(true)



# 查看各自的余额
$ dfx canister call token1 balanceOf "($Alice)"
(900)

$ dfx canister call token1 balanceOf "($Bob)"
(100)

$ dfx canister call token2 balanceOf "($Alice)"
(300)

$ dfx canister call token2 balanceOf "($Bob)"
(700)

# 原子交换完成
```
