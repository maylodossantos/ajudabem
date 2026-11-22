package com.ajudabem.api.repositories;

import com.ajudabem.api.domains.initiative.Campaign;
import com.ajudabem.api.domains.initiative.CampaignCategory;
import com.ajudabem.api.domains.initiative.InitiativeStatus;
import com.ajudabem.api.domains.news.News;
import com.ajudabem.api.domains.news.NewsCategory;
import com.ajudabem.api.domains.organization.Organization;
import com.ajudabem.api.domains.organization.OrganizationStatus;
import com.ajudabem.api.domains.user.User;
import com.ajudabem.api.domains.user.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
class PublicationTableTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private OrganizationRepository organizationRepository;

    @Autowired
    private NewsRepository newsRepository;

    @Autowired
    private CampaignRepository campaignRepository;

    private User persistUser(String email) {
        User user = new User();
        user.setName("User");
        user.setEmail(email);
        user.setPassword("hashed");
        user.setPhone("49999990000");
        user.setRole(UserRole.USER_ONG);
        return userRepository.save(user);
    }

    @Test
    void newsAndCampaignsShareOneTableWithoutMixingQueriesOrIds() {
        User author = persistUser("publisher@example.com");

        Organization organization = new Organization();
        organization.setOwner(author);
        organization.setTradeName("ONG");
        organization.setCnpj("11222333000181");
        organization.setStatus(OrganizationStatus.APPROVED);
        organizationRepository.save(organization);

        News news = new News();
        news.setAuthor(author);
        news.setTitle("Notícia");
        news.setContent("Texto da notícia");
        news.setCategory(NewsCategory.HEALTH);
        newsRepository.save(news);

        Campaign campaign = new Campaign();
        campaign.setOrganization(organization);
        campaign.setTitle("Campanha");
        campaign.setDescription("Texto da campanha");
        campaign.setCategory(CampaignCategory.FOOD);
        campaign.setStatus(InitiativeStatus.ACTIVE);
        campaignRepository.save(campaign);

        entityManager.flush();
        entityManager.clear();

        assertThat(news.getId()).isNotEqualTo(campaign.getId());
        assertThat(newsRepository.findAll()).extracting(News::getTitle).containsExactly("Notícia");
        assertThat(campaignRepository.findAll()).extracting(Campaign::getTitle).containsExactly("Campanha");
        assertThat(newsRepository.findById(campaign.getId())).isEmpty();
        assertThat(campaignRepository.findById(news.getId())).isEmpty();
        assertThat(campaignRepository.findById(campaign.getId()))
                .get()
                .extracting(Campaign::getDescription)
                .isEqualTo("Texto da campanha");

        Object kinds = entityManager.getEntityManager()
                .createNativeQuery("SELECT COUNT(DISTINCT kind) FROM publications")
                .getSingleResult();
        assertThat(((Number) kinds).intValue()).isEqualTo(2);
    }
}
