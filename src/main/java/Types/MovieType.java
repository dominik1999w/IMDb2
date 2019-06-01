package Types;

import java.sql.Date;

public class MovieType {
    private Integer movie_id;
    private String title;
    private Date release_date;
    private String runtime;
    private Integer budget;
    private Integer boxoffice;
    private Integer opening_weekend_usa;
    private String description;

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

    public Date getRelease_date() {
        return release_date;
    }

    public void setRelease_date(Date release_date) {
        this.release_date = release_date;
    }

    public String getRuntime() {
        return runtime;
    }

    public void setRuntime(String runtime) {
        this.runtime = runtime;
    }

    public Integer getBudget() {
        return budget;
    }

    public void setBudget(Integer budget) {
        this.budget = budget;
    }

    public Integer getBoxoffice() {
        return boxoffice;
    }

    public void setBoxoffice(Integer boxoffice) {
        this.boxoffice = boxoffice;
    }

    public Integer getOpening_weekend_usa() {
        return opening_weekend_usa;
    }

    public void setOpening_weekend_usa(Integer opening_weekend_usa) {
        this.opening_weekend_usa = opening_weekend_usa;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public MovieType(Integer movie_id, String title, Date release_date, String runtime, Integer budget, Integer boxoffice, Integer opening_weekend_usa, String description) {
        this.movie_id = movie_id;
        this.title = title;
        this.release_date = release_date;
        this.runtime = runtime;
        this.budget = budget;
        this.boxoffice = boxoffice;
        this.opening_weekend_usa = opening_weekend_usa;
        this.description = description;
    }
}
