package Types;

public class PersonRankingType {
    private Integer ranking;
    private Integer person_id;
    private String name;
    private Double avg_mark;
    private Integer votes;

    public Integer getRanking() {
        return ranking;
    }

    public Integer getPerson_id() {
        return person_id;
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

    public Integer getVotes() {
        return votes;
    }

    public PersonRankingType(Integer ranking, Integer person_id, String name, Double avg_mark, Integer votes) {
        this.ranking = ranking;
        this.person_id = person_id;
        this.name = name;
        this.avg_mark = avg_mark;
        this.votes = votes;
    }
}
