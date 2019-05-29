package Types;

public class MovieRankingType {
    Integer ranking;
    Integer movie_id;
    String title;
    Double avg_mark;
    Integer votes;

    public Integer getRanking() {
        return ranking;
    }

    public void setRanking(Integer ranking) {
        this.ranking = ranking;
    }

    public Integer getMovie_id() {
        return movie_id;
    }

    public void setMovie_id(Integer movie_id) {
        this.movie_id = movie_id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public Double getAvg_mark() {
        return avg_mark;
    }

    public void setAvg_mark(Double avg_mark) {
        this.avg_mark = avg_mark;
    }

    public Integer getVotes() {
        return votes;
    }

    public void setVotes(Integer votes) {
        this.votes = votes;
    }

    public MovieRankingType(Integer ranking, Integer movie_id, String title, Double avg_mark, Integer votes) {
        this.ranking = ranking;
        this.movie_id = movie_id;
        this.title = title;
        this.avg_mark = avg_mark;
        this.votes = votes;
    }
}
