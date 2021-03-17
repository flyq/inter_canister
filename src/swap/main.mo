import Token1 "canister:token1";
import Token2 "canister:token2";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";

actor class Test() = this {
    // owner 愿意使用 from_amount 个 from_token 来兑换成 to_amount 个 to_token.
    type Order = {
        owner: Principal;
        from_token: Principal;
        from_amount: Nat;
        to_token: Principal;
        to_amount: Nat;
    };

    private var orders = HashMap.HashMap<Principal, Order>(1, Principal.equal, Principal.hash);
    
    public shared(msg) func pending(_from_token: Principal, _from_amount: Nat, _to_token: Principal, _to_amount: Nat) : async Bool {
        var order : Order = {
            owner = msg.caller;
            from_token = _from_token;
            from_amount = _from_amount;
            to_token = _to_token;
            to_amount = _to_amount;
        };
        orders.put(msg.caller, order);
        return true;
    };

    public shared(msg) func deleteOrder() : async Bool {
        switch (orders.get(msg.caller)) {
            case (?order) {
                orders.delete(msg.caller);
                return true;
            };
            case (_) {
                return false;
            };
        }
    };

    public shared(msg) func deal(who: Principal) : async Bool {
        switch (orders.get(who)) {
            case (?order) {
                var _fromer = order.owner;
                var _from_amount = order.from_amount;
                var _toer = msg.caller;
                var _to_amount = order.to_amount;
                // assert(Token1.identifier == order.from_token); 等等，假设 Token1 是 from token，Token2 是 to token。
                
                var _canister_id = Principal.fromActor(this);

                var _token1_allowd = await Token1.allowance(_fromer, _canister_id);
                var _token1_from_balance = await Token1.balanceOf(_fromer);
                assert(_token1_allowd >= _from_amount and _token1_from_balance >= _from_amount);

                var _token2_allowd = await Token2.allowance(_toer, _canister_id);
                var _token2_to_balance = await Token2.balanceOf(_toer);
                assert(_token2_allowd >= _to_amount and _token2_to_balance >= _to_amount);

                var res1 = await Token1.transferFrom(_fromer, _toer , _from_amount);
                assert(res1);
                var res2 = await Token2.transferFrom(_toer, _fromer, _to_amount);
                assert(res2);
		        orders.delete(who);
                return true;
            };
            case (_) {
                return false;
            };
        }
    };

    public query func getOrder(who: Principal) : async ?Order {
        return orders.get(who);
    };
}