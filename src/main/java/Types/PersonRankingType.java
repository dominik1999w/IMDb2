package Types;

public class PersonRankingType {
    Integer ranking;
    Integer person_id;
    String name;
    Double avg_mark;
    Integer votes;
    public Integer getRanking() {
        return ranking;
    }

    public void setRanking(Integer ranking) {
        this.ranking = ranking;
    }

    public Integer getPerson_id() {
        return person_id;
    }

    public void setPerson_id(Integer person_id) {
        this.person_id = person_id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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
    public PersonRankingType(Integer ranking, Integer person_id, String name, Double avg_mark, Integer votes) {
        this.ranking = ranking;
        this.person_id = person_id;
        this.name = name;
        this.avg_mark = avg_mark;
        this.votes = votes;
    }
}
