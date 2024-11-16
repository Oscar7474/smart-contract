// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract TreasureHunt {
    // 定義主辦人的地址、公益機構的地址、遊戲狀態（是否結束）、參加費用和寶藏獎金的變數
    address public organizer;  // 主辦人地址
    address public charity;    // 公益機構地址
    bool public gameEnded;     // 遊戲是否結束的狀態
    uint public entryFee;      // 每位參與者的參加費用
    uint public prizeAmount;   // 寶藏獎金數額
    address[] public hunters;  // 儲存所有參與者的地址

    // 記錄每位參與者貢獻的金額
    mapping(address => uint) public contributions;

    // 定義事件
    event Entry(address hunter);              // 記錄參與者加入遊戲
    event TreasureClaimed(address winner, uint amount); // 記錄獲勝者及獎金
    event DonationMade(address charity, uint amount);   // 記錄捐款動作

    // 構造函數，用於初始化合約
    constructor(address _charity, uint _entryFee, uint _prizeAmount) {
        organizer = msg.sender; // 設置主辦人的地址為創建合約的地址
        charity = _charity;     // 設置公益機構的地址
        entryFee = _entryFee;   // 設置參加費用
        prizeAmount = _prizeAmount; // 設置寶藏獎金
        gameEnded = false;      // 初始遊戲狀態為未結束
    }

    // 參加寶藏狩獵活動的函數
    function joinHunt() public payable {
        // 確保參與者支付的費用符合最低要求
        require(msg.value >= entryFee, "Entry fee is required");
        // 確保遊戲未結束
        require(!gameEnded, "Game has already ended");

        // 將參與者的地址加入 hunters 陣列，並記錄他們的貢獻
        hunters.push(msg.sender);
        contributions[msg.sender] += msg.value;
        // 發出參加遊戲的事件
        emit Entry(msg.sender);
    }

    // 主辦人選出隨機獲勝者並將獎金頒發給他們
    function claimTreasure() public {
        // 僅允許主辦人執行此操作
        require(msg.sender == organizer, "Only organizer can claim the treasure");
        // 確保至少有一位參與者
        require(hunters.length > 0, "No hunters have joined");
        // 確保遊戲尚未結束
        require(!gameEnded, "Game has already ended");

        // 使用隨機數字生成一個獲勝者的索引
        uint winnerIndex = uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % hunters.length;
        address winner = hunters[winnerIndex]; // 選擇對應索引的參與者為贏家
        
        // 向獲勝者發送寶藏獎金
        payable(winner).transfer(prizeAmount);
        // 發出獎金發放的事件
        emit TreasureClaimed(winner, prizeAmount);
        gameEnded = true; // 設置遊戲狀態為結束

        // 將剩餘的資金捐贈給公益機構
        uint donationAmount = address(this).balance;
        payable(charity).transfer(donationAmount);
        // 發出捐贈的事件
        emit DonationMade(charity, donationAmount);
    }

    // 查詢合約的餘額
    function getBalance() public view returns (uint) {
        return address(this).balance;  // 返回合約當前的餘額
    }
}
