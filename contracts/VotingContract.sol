// SPDX-License-Identifier: MIT
pragma solidity >0.8.12;

interface IToken {
    function transferFrom(address, address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function balanceOf(address) external returns (uint256);

    function totalSupply() external returns (uint256);
}

contract VotingContract {
    struct Proposal {
        string description;
        uint256 yesCount;
        uint256 noCount;
        uint256 timestamp;
    }

    struct UserVoteDetail {
        bool yesNo;
        bool voted;
        uint256 amount;
        uint256 lockedUntil;

    }

    // address public votingToken;

    //IToken public voting token;
    IToken public votingToken;
    Proposal[] public proposals;

    uint256 public proposalCount;
    uint256 proposalFee = 20 * 10 ** 18;

    mapping(address => mapping(uint256 => UserVoteDetail)) public userVotePool;
    mapping(uint256 => bool) public resultProposals;

    event CastVote(address, uint256, bool);
    event Finalize(uint256, bool);
    event CreateProposal(uint256, string);
    event WithdrawlToken(  address, uint256 , uint256);

    modifier checkProposalEnded(uint256 _proposalId) {
        require(
            block.timestamp < proposals[_proposalId].timestamp,
            "Proposal ended"
        );
        _;
    }

    constructor(address _votingToken) {
        proposalCount = 0;
        votingToken = IToken(_votingToken);
    }

    function createProposal(string memory _desc) public {
        votingToken.transferFrom(msg.sender, address(this), proposalFee);
        Proposal memory proposal = Proposal(
            _desc,
            0,
            0,
            block.timestamp + 3 days
        );
        proposals.push(proposal);
        ++proposalCount;
        emit CreateProposal(proposalCount, _desc);
    }

    // function castVote( uint256 _proposalId , bool _isApproved ) public checkProposalEnded(_proposalId) {
    //     require(!hasVoted[msg.sender][_proposalId] , "You voted for this proposal already! cant vote more");
    //     uint256 totalToken = votingToken.balanceOf( msg.sender );
    //     if(_isApproved){
    //         proposals[_proposalId].yesCount += totalToken;
    //     }else{
    //         proposals[_proposalId].noCount += totalToken;
    //     }

    //     hasVoted[msg.sender][_proposalId] = true;

    //     emit CastVote(msg.sender, _proposalId, _isApproved);
    // }

    //cast vote with token attacked and locked for x months
    function castVote(
        uint256 _proposalId,
        bool _isApproved,
        uint256 _amount,
        uint256 _months
    ) public checkProposalEnded(_proposalId) {
        require(
            !userVotePool[msg.sender][_proposalId].voted,
            "You voted for this proposal already! cant vote more"
        );
        require(
            _months == 1 || _months == 6 || _months == 12,
            "Must lock token for 1, 6 or 12 months!"
        );
        //   uint256 totalToken = votingToken.balanceOf( msg.sender );

        votingToken.transferFrom(msg.sender, address(this), _amount);
        UserVoteDetail memory uv = UserVoteDetail(
            _isApproved,
            true,
            _amount,
            block.timestamp + _months*30 days
        );
        userVotePool[msg.sender][_proposalId] = uv;

        if (_isApproved) {
            proposals[_proposalId].yesCount += _amount * _months;
        } else {
            proposals[_proposalId].noCount += _amount * _months;
        }

        emit CastVote(msg.sender, _proposalId, _isApproved);
    }

    // function finalizeProposal(uint256 _proposalId) public {
    //     require(block.timestamp >= proposals[_proposalId].timestamp , "The proposal is not ended yet");
    //     uint256 yesCount = proposals[_proposalId].yesCount;
    //     uint256 totalSupply = votingToken.totalSupply();
    //     uint256 totalYesVote = (yesCount / totalSupply) * 100;
    //     if (totalYesVote > 50) {
    //         resultProposals[_proposalId] = true;
    //     }else{
    //         resultProposals[_proposalId] = false;
    //     }

    //     emit Finalize(_proposalId, resultProposals[_proposalId] );
    // }

    function finalizeProposal(uint256 _proposalId) public {
        require(
            block.timestamp >= proposals[_proposalId].timestamp,
            "The proposal is not ended yet"
        );
        uint256 noCount = proposals[_proposalId].noCount;
        uint256 yesCount = proposals[_proposalId].yesCount;
        uint256 totalVotes = yesCount +  noCount;
        uint256 totalYesVote = (yesCount / totalVotes) * 100;
        if (totalYesVote > 50) {
            resultProposals[_proposalId] = true;
        } else {
            resultProposals[_proposalId] = false;
        }

        emit Finalize(_proposalId, resultProposals[_proposalId]);
    }

    function withdrawlTokenFromProposal( uint256 _proposalId ) public {
        UserVoteDetail memory voteDetail = userVotePool[msg.sender][_proposalId];
        require( voteDetail.voted && voteDetail.amount > 0 , "You didn't vote for this proposal or token already withdrawn before" );
        require( block.timestamp >= voteDetail.lockedUntil  , "Token locked time is not ended yet!" );
        votingToken.approve( address(this), voteDetail.amount );
        votingToken.transferFrom( address(this) , msg.sender , voteDetail.amount );
        userVotePool[msg.sender][_proposalId].amount = 0;
        emit WithdrawlToken( msg.sender, _proposalId, voteDetail.amount );
    }
}
