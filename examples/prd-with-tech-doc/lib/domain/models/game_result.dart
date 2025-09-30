import 'player.dart';

enum GameResult {
  win,
  loss,
  draw,
  ongoing;

  String displayText(Player winner) {
    switch (this) {
      case GameResult.win:
        return '${winner.symbol} Wins!';
      case GameResult.loss:
        return '${winner.symbol} Wins!';
      case GameResult.draw:
        return "It's a Draw!";
      case GameResult.ongoing:
        return '';
    }
  }
}
