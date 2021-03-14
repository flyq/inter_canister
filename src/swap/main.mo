import Token1 "canister:token1";
import Token2 "canister:token2";
import Principal "mo:base/Principal";

shared({ caller }) actor class Swap() {

    // owner 愿意使用 from_amount 个 from_token 来兑换成 to_amount 个 to_token.
    type Order = {
        owner: Principal;
        from_token: Principal;
        from_amount: Nat;
        to_token: Principal;
        to_amount: Nat;
    };

    private var orders = HashMap.HashMap<Principal, Order>(1, Principal.equal, Principal.hash);
    
    public shared({ caller }) func pending(_from_token: Principal, _from_amount: Nat, _to_token: Principal, _to_amount: Nat) : async Bool {
        switch (orders.get(caller)) {
            case (?order) {
                order.owner = caller;
                order.from_token = _from_token;
                order.from_amount = _from_amount;
                order.to_token = _to_token;
                order.to_amount = _to_amount;
                orders.put(caller, order);
                return true;
            };
            case (_) {
                var order : Order = {
                    owner = caller;
                    from_token = _from_token;
                    from_amount = _from_amount;
                    to_token = _to_token;
                    to_amount = _to_amount;
                };
                orders.put(caller, order);
                return true;
            };
        }
    };

    public shared({ caller }) func deleteOrder() : async Bool {
        switch (orders.get(caller)) {
            case (?order) {
                orders.delete(caller);
                return true;
            };
            case (_) {
                return false;
            };
        }
    };

    public shared({ caller }) func deal(who: Principal) : async Bool {
        switch (orders.get(who)) {
            case (?order) {
                _fromer = order.owner;
                _from_amount = order.from_amount;
                _toer = caller;
                _to_amount = order.to_amount;
                // assert(Token1.标识符 == order.from_token); 等等，假设 Token1 是 from token，Token2 是 to token。
                Token1.transferFrom(_fromer, _toer , _from_amount)
                Token2.transferFrom(_toer, _fromer, _to_amount);
                return true;
            };
            case (_) {
                return false;
            };
        }
    };

    public query func getOrder(who: Principal) : async ?Order {
        return orders.get(who));
    };
}